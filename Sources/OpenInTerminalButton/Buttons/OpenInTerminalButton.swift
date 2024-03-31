//
//  OpenInTerminalButton.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.3.2024.
//

import SwiftUI

public struct OpenInTerminalButton: View {
    let location: URL
    let commands: [String]

    public init(location: URL, commands: [String]) {
        self.location = location
        self.commands = commands
    }

    public var body: some View {
        BorderlessButton(action: {
            DispatchQueue.global().async {
                Task {
                    let result = try await openInTerminal(location: location, commands: commands)
                    if case let .failure(error) = result {
                        print("Failed to open \(self.location) with commands \(self.commands) in terminal: \(error)")
                    }
                }
            }
        }, label: {
            Image(systemName: "apple.terminal")
        }, helpString: "Open in Terminal")
    }
}
