// Copyright (c) 2026 Jakub Kubiak.

@testable import Data
import Foundation
import Nimble
import XCTest

final class AeroSpaceEventClientTests: XCTestCase {
    func testDecodesFocusChangedEvent() throws {
        let data = Data(#"{"_event":"focus-changed","windowId":28218,"workspace":"M"}"#.utf8)

        let event = try JSONDecoder().decode(AeroSpaceEvent.self, from: data)

        expect(event.name) == "focus-changed"
        expect(event.windowId) == 28_218
        expect(event.workspace) == "M"
    }

    func testDecodesFocusedWorkspaceChangedEvent() throws {
        let data = Data(#"{"_event":"focused-workspace-changed","prevWorkspace":"1","workspace":"2"}"#.utf8)

        let event = try JSONDecoder().decode(AeroSpaceEvent.self, from: data)

        expect(event.name) == "focused-workspace-changed"
        expect(event.previousWorkspace) == "1"
        expect(event.workspace) == "2"
    }

    func testDecodesWindowDetectedEvent() throws {
        let json = """
        {
            "_event": "window-detected",
            "windowId": 42,
            "workspace": "3",
            "appBundleId": "com.apple.Safari",
            "appName": "Safari"
        }
        """
        let data = Data(json.utf8)

        let event = try JSONDecoder().decode(AeroSpaceEvent.self, from: data)

        expect(event.name) == "window-detected"
        expect(event.windowId) == 42
        expect(event.workspace) == "3"
        expect(event.appBundleId) == "com.apple.Safari"
        expect(event.appName) == "Safari"
    }
}
