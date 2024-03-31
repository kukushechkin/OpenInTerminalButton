//
//  OpenInTerminal.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.03.2024.
//

import AppKit

// MARK: - Public interface

public enum OpenInTerminalError: Error, Equatable {
    case noTerminalFound
    case failedToInitializeAppleScript
    case failedToExecuteAppleScript(String)
}

public enum SupportedTerminal: String, CaseIterable {
    case terminal = "com.apple.Terminal"
    case iterm2 = "com.googlecode.iterm2"
}

public func openInTerminal(location: URL, commands: [String]?) async throws -> Result<SupportedTerminal, OpenInTerminalError> {
    guard let terminal = terminalToUse(),
          let terminalURL = URLFor(terminal: terminal)
    else {
        return .failure(.noTerminalFound)
    }

    // No need to use Apple Events if there is no commands to execute
    if let commands = commands, !commands.isEmpty {
        return openLocationAndRunCommands(location, commands: commands, terminalURL: terminalURL, terminal: terminal)
    } else {
        return try await openLocation(location, terminalURL: terminalURL, terminal: terminal)
    }
}

// MARK: - Unit tests support

// Unit tests will override these variables
struct OpenInTerminalInernals {
    var workspace: NSWorkspace = .shared
    var appleScriptClass = NSAppleScript.self
}

var openInTerminalInternals = OpenInTerminalInernals()

// MARK: - Internal

let commandsPlaceholder = "COMMANDS_PLACEHOLDER"

func appleScript(for terminal: SupportedTerminal) -> String {
    switch terminal {
    case .iterm2:
        return openiTerm2AndRunCommandsScript
    case .terminal:
        return openTerminalAndRunCommandsScript
    }
}

func insert(commands: [String], to scriptString: String) -> String {
    let commandsStr = commands.joined(separator: ";")
    return scriptString.replacingOccurrences(of: commandsPlaceholder, with: commandsStr)
}

// Select terminals based on this priority list
let terminalsPriority: [SupportedTerminal] = [.iterm2, .terminal]

func URLFor(terminal: SupportedTerminal) -> URL? {
    return openInTerminalInternals.workspace.urlForApplication(withBundleIdentifier: terminal.rawValue)
}

func terminalToUse() -> SupportedTerminal? {
    terminalsPriority.first { terminal in
        URLFor(terminal: terminal) != nil
    }
}

func openLocation(
    _ url: URL,
    terminalURL _: URL,
    terminal: SupportedTerminal
) async throws -> Result<SupportedTerminal, OpenInTerminalError> {
    try await openInTerminalInternals.workspace.open([url], withApplicationAt: url, configuration: NSWorkspace.OpenConfiguration())
    return .success(terminal)
}

func openLocationAndRunCommands(
    _: URL,
    commands: [String],
    terminalURL _: URL,
    terminal: SupportedTerminal
) -> Result<SupportedTerminal, OpenInTerminalError> {
    let script = appleScript(for: terminal)
    switch runAppleScript(script, commands: commands) {
    case .success:
        return .success(terminal)
    case let .failure(error):
        return .failure(error)
    }
}

func runAppleScript(_ scriptString: String, commands: [String]) -> Result<Void, OpenInTerminalError> {
    let updatedSource = insert(commands: commands, to: scriptString)
    guard let updatedScript = openInTerminalInternals.appleScriptClass.init(source: updatedSource)
    else {
        return .failure(.failedToInitializeAppleScript)
    }
    var errorsDict: NSDictionary?
    updatedScript.executeAndReturnError(&errorsDict)
    if let errorsDict = errorsDict {
        return .failure(.failedToExecuteAppleScript(errorsDict.description))
    }
    return .success(())
}
