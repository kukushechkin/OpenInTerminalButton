//
//  OpenInTerminalButtonTests.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.3.2024.
//

@testable import OpenInTerminalButton
import XCTest

final class OpenInTerminalButtonTests: XCTestCase {
    func testAppleScriptCommandsInsertion() throws {
        let someCommands = ["ls", "cd ~/Downloads"]
        let someScript = """
        tell application "Terminal"
            do script "\(commandsPlaceholder)"
        end tell
        """
        let expectedScript = """
        tell application "Terminal"
            do script "ls;cd ~/Downloads"
        end tell
        """
        let result = insert(commands: someCommands, to: someScript)
        XCTAssertEqual(result, expectedScript)
    }

    // MARK: - Test URLFor

    func testURLForTerminal() throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace

        let terminalURL = URL(fileURLWithPath: "/Applications/FakeTerminal.app")
        workspace.urlsForApplications = [SupportedTerminal.terminal.rawValue: terminalURL]
        let result = URLFor(terminal: .terminal)
        XCTAssertEqual(result, terminalURL)
    }

    // MARK: - Test priorities

    func testNoTerminals() throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace

        // no any terminal
        workspace.urlsForApplications = [:]
        let result = terminalToUse()
        XCTAssertNil(result)
    }

    func testOnlyTerminalApp() throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace

        // Terminal.app is present, no iTerm2.app
        let terminalURL = URL(fileURLWithPath: "/Applications/FakeTerminal.app")
        workspace.urlsForApplications = [SupportedTerminal.terminal.rawValue: terminalURL]
        let result = terminalToUse()
        XCTAssertEqual(result, .terminal)
    }

    func testBothTerminals() throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace

        // not Terminal.app and iTerm2.app are present
        let terminalURL = URL(fileURLWithPath: "/Applications/FakeTerminal.app")
        let iTerm2URL = URL(fileURLWithPath: "/Applications/FakeiTerm2.app")
        workspace.urlsForApplications = [
            SupportedTerminal.terminal.rawValue: terminalURL,
            SupportedTerminal.iterm2.rawValue: iTerm2URL,
        ]
        let result = terminalToUse()
        XCTAssertEqual(result, .iterm2)
    }

    // MARK: - Test openLocation

    func testOpenLocation() async throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace

        let url = URL(fileURLWithPath: "/Users")
        let terminalURL = URL(fileURLWithPath: "/Applications/FakeTerminal.app")
        workspace.urlsForApplications = [SupportedTerminal.terminal.rawValue: terminalURL]
        var result = try await openLocation(url, terminalURL: terminalURL, terminal: .terminal)
        XCTAssertEqual(try? result.get(), .terminal)
        XCTAssertEqual(workspace.openedLocations, [url.absoluteString])

        result = try await openLocation(url, terminalURL: terminalURL, terminal: .terminal)
        XCTAssertEqual(try? result.get(), .terminal)
        XCTAssertEqual(workspace.openedLocations, [url.absoluteString, url.absoluteString])
    }

    // MARK: Apple Scripts tests

    // I am not sure what kind of script string is invalid,
    // even something like "tell application \"Finder\" to sing a song"
    // seems to construct NSAppleScript.
    func testAllDefinedScriptsCanBeLoaded() throws {
        XCTAssertNotNil(NSAppleScript(source: "tell application \"Finder\" to sing a song"))
        for terminal in SupportedTerminal.allCases {
            let script = appleScript(for: terminal)
            XCTAssertNotNil(script)
            XCTAssertNotNil(NSAppleScript(source: script))
        }
    }

    func testScriptExecution() throws {
        openInTerminalInternals.appleScriptClass = NSAppleScriptMock.self
        let commands = ["command a", "commands b"]
        let script = "tell application \"Finder\" to sing a song \(commandsPlaceholder)"
        let expectedToRunScript = "tell application \"Finder\" to sing a song \(commands.joined(separator: ";"))"
        NSAppleScriptMock.executedScripts = []

        // First run should be successful
        NSAppleScriptMock.errorInfo = nil
        var result = runAppleScript(script, commands: commands)
        if case let .failure(error) = result {
            XCTFail("Should've succeeded: \(error)")
        }
        XCTAssertEqual(NSAppleScriptMock.executedScripts, [expectedToRunScript])

        // Second will fail
        NSAppleScriptMock.errorInfo = ["some": "error"]
        result = runAppleScript(script, commands: commands)
        if case let .success(result) = result {
            XCTFail("Should have failed, but got \(result)")
        }
        if case let .failure(error) = result,
           case let OpenInTerminalError.failedToExecuteAppleScript(info) = error
        {
            XCTAssertEqual(info, """
            {
                some = error;
            }
            """)
        }
        XCTAssertEqual(NSAppleScriptMock.executedScripts, [expectedToRunScript, expectedToRunScript])
    }

    // MARK: - Test openInTerminal

    func testOpenInTerminalNoTerminalFound() async throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace

        let url = URL(fileURLWithPath: "/Users")
        let result = try await openInTerminal(location: url, commands: nil)
        if case let .failure(error) = result {
            XCTAssertEqual(error, .noTerminalFound)
        } else {
            XCTFail("Should've failed")
        }
    }

    func testOpenInTerminalNoCommands() async throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace

        let url = URL(fileURLWithPath: "/Users")
        let terminalURL = URL(fileURLWithPath: "/Applications/FakeTerminal.app")
        workspace.urlsForApplications = [SupportedTerminal.terminal.rawValue: terminalURL]
        let result = try await openInTerminal(location: url, commands: nil)
        XCTAssertEqual(try? result.get(), .terminal)
        XCTAssertFalse(workspace.openedLocations.isEmpty)
    }

    func testOpenInTerminalCommands() async throws {
        let workspace = NSWorkspaceMock()
        openInTerminalInternals.workspace = workspace
        openInTerminalInternals.appleScriptClass = NSAppleScriptMock.self

        let url = URL(fileURLWithPath: "/Users")
        let terminalURL = URL(fileURLWithPath: "/Applications/FakeTerminal.app")
        workspace.urlsForApplications = [SupportedTerminal.terminal.rawValue: terminalURL]
        let result = try await openInTerminal(location: url, commands: ["ls", "cd ~/Downloads"])
        XCTAssertEqual(try? result.get(), .terminal)
        XCTAssertTrue(workspace.openedLocations.isEmpty)
        XCTAssertFalse(NSAppleScriptMock.executedScripts.isEmpty)
    }
}
