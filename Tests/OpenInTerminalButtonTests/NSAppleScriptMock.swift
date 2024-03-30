//
//  NSAppleScriptMock.swift
//  OpenInTerminalButton
//
//  Created by Vladimir Kukushkin on 30.3.2024.
//

@testable import OpenInTerminalButton
import XCTest

class NSAppleScriptMock: NSAppleScript {
    static var executedScripts: [String] = []
    static var errorInfo: [String: Any]?

    // - (NSAppleEventDescriptor *)executeAndReturnError:(NSDictionary<NSString *, id> * _Nullable * _Nullable)errorInfo;
    override func executeAndReturnError(_ errorInfo: AutoreleasingUnsafeMutablePointer<NSDictionary?>?) -> NSAppleEventDescriptor {
        let script = source!
        Self.executedScripts.append(script)
        errorInfo?.pointee = Self.errorInfo as NSDictionary?
        return NSAppleEventDescriptor()
    }
}
