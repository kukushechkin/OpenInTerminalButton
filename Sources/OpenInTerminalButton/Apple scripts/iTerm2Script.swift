//
//  iTerm2Script.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.03.2024.
//

// This script is used to open iTerm2.app and run commands in it
let openiTerm2AndRunCommandsScript = """
-- AppleScript
tell application "iTerm"
    try
        -- Try to use the current window
        set currentWindow to current window
    on error
        -- If no current window, create a new one
        set currentWindow to (create window with default profile)
    end try

    tell currentWindow
        -- Create a new tab
        set newTab to (create tab with default profile)
        tell newTab
            -- Every tab has at least one session, here we target the current session in the new tab
            set currentSession to current session
            tell currentSession
                -- Execute the echo command in the current session
                write text "COMMANDS_PLACEHOLDER"
            end tell
        end tell
        if is hotkey window then
            reveal hotkey window
        else
            select
        end if
    end tell
end tell
"""
