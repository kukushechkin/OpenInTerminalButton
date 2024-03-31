[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkukushechkin%2FOpenInTerminalButton%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kukushechkin/OpenInTerminalButton)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkukushechkin%2FOpenInTerminalButton%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kukushechkin/OpenInTerminalButton)

# OpenInTerminalButton

A tiny SwiftPM package that provides a library and a SwiftUI button for opening a folder in macOS Terminal.app or iTerm2.app.

## Comptbitility

For obvious reasons, this package is macOS-only. 
Apple Events can be used in sandbox only with a temporary exception, but even if you manage to get one,
that app will, most probably, [not pass the App Store review process](https://developer.apple.com/forums/thread/663311?answerId=639603022#639603022).

## Public interface

- `struct OpenInTerminalButton: View` - a SwiftUI button that opens the current Finder window in Terminal.app or iTerm2.app.
- `struct BorderlessButton: View` - a SwuftUI button without a border and background.
- `enum OpenInTerminalError` — an enumeration of possible errors.
- `enum SupportedTerminal` — an enumeration of possible terminal applications.
- `func openInTerminal(location: URL, commands: [String]?) -> Result<SupportedTerminal, OpenInTerminalError>` — a function that opens the specified location in Terminal.app or iTerm2.app and runs the specified commands.

## Usage

1. Add a dependency in your `Package.swift`:

```swift
.package(url: "https://github.com/kukushechkin/OpenInTerminalButton", .upToNextMajor(from: "1.0.0"))
```

2. Add Apple Events to the `Info.plist` of your app:

```xml
<key>NSAppleEventsUsageDescription</key>
<string>Allow this app to open terminal app and execute commands.</string> 
```

3. Use the `OpenInTerminalButton` view:

```swift
import SwiftUI
import OpenInTerminalButton

struct ContentView: View {
    var body: some View {
        OpenInTerminalButton(
            location: URL(fileURLWithPath: "~/Desktop"),
            commands: [
                "echo 'Hello, world!'",
                "ls -la"
            ]
        )
    }
}
```

After clicking on the button, a new iTerm2.app (if installed) or Terminal window will open with the specified commands.
If you're using Hotkey Window in iTerm2.app, a new tab will open in the existing window.

4. Use `openInTerminal(location:commands:)` function directly, for example if you would like to create a custom button:

```swift
import OpenInTerminalButton

let result = openInTerminal(location: URL(fileURLWithPath: "~/Desktop"), commands: ["echo 'Hello, world!'"])
switch result {
case .success(let terminal):
    print("Opened in \(terminal)")
case .failure(let error):
    print("Error: \(error)")
}
```
