//
//  BorderlessButton.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.03.2024.
//

import SwiftUI

public struct BorderlessButton<LabelView: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> LabelView
    let helpString: String

    public init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> LabelView, helpString: String) {
        self.action = action
        self.label = label
        self.helpString = helpString
    }

    public var body: some View {
        Button(action: action, label: label)
            .buttonStyle(.borderless)
            .help(helpString)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
    }
}
