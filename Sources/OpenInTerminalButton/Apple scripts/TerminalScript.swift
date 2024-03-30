//
//  TerminalScript.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.03.2024.
//

// This script is used to open Terminal.app and run commands in it
let openTerminalAndRunCommandsScript = """
-- AppleScript
tell application "Terminal"
    activate
    -- Open a new window and execute the command
    do script "COMMANDS_PLACEHOLDER"
end tell
"""
