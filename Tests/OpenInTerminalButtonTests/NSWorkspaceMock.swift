//
//  NSWorkspaceMock.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.3.2024.
//

@testable import OpenInTerminalButton
import XCTest

class NSWorkspaceMock: NSWorkspace {
    var urlsForApplications: [String: URL] = [:]
    var openedLocations: [String] = []

    override func urlForApplication(withBundleIdentifier bundleIdentifier: String) -> URL? {
        return urlsForApplications[bundleIdentifier]
    }

    override func open(
        _ urls: [URL],
        withApplicationAt _: URL,
        configuration _: NSWorkspace.OpenConfiguration
    ) async throws -> NSRunningApplication {
        openedLocations.append(urls.first!.absoluteString)
        return NSRunningApplication()
    }
}
