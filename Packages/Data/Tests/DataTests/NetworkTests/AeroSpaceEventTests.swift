// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Data
import Domain
import Nimble
import XCTest

/// Tests decoding of the event payloads AeroSpace emits on its subscription socket.
///
/// AeroSpace omits `nil` fields when encoding, so the absent-optional cases below
/// are the shapes actually seen on the wire, not hypotheticals.
final class AeroSpaceEventTests: XCTestCase {
    // MARK: - Helpers

    /// Decodes an event from a JSON string.
    /// - Parameter json: The JSON payload of one frame
    /// - Returns: The decoded event, or nil for an unrecognised event type
    private func decode(_ json: String) throws -> AeroSpaceEvent? {
        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to encode fixture as UTF-8")
            return nil
        }

        return try AeroSpaceEvent.decode(from: data)
    }

    // MARK: - Fully Populated Payloads

    func testDecodesFocusChanged() throws {
        // Given a focus-changed payload with a focused window
        let json = #"{"_event":"focus-changed","windowId":13094,"workspace":"1"}"#

        // When decoding
        let event = try decode(json)

        // Then it maps to focusChanged with both fields
        expect(event) == .focusChanged(windowId: 13_094, workspace: "1")
    }

    func testDecodesFocusedMonitorChanged() throws {
        // Given a focused-monitor-changed payload
        let json = #"{"_event":"focused-monitor-changed","monitorId":1,"workspace":"1"}"#

        // When decoding
        let event = try decode(json)

        // Then the 1-based monitor id is preserved
        expect(event) == .focusedMonitorChanged(workspace: "1", monitorId: 1)
    }

    func testDecodesFocusedWorkspaceChanged() throws {
        // Given a focused-workspace-changed payload
        let json = #"{"_event":"focused-workspace-changed","prevWorkspace":"1","workspace":"4"}"#

        // When decoding
        let event = try decode(json)

        // Then both the new and previous workspace are captured
        expect(event) == .focusedWorkspaceChanged(workspace: "4", previousWorkspace: "1")
    }

    func testDecodesModeChanged() throws {
        // Given a mode-changed payload with an active mode
        let json = #"{"_event":"mode-changed","mode":"main"}"#

        // When decoding
        let event = try decode(json)

        // Then the mode is captured
        expect(event) == .modeChanged(mode: "main")
    }

    func testDecodesWindowDetected() throws {
        // Given a fully populated window-detected payload
        let json = """
        {"_event":"window-detected","appBundleId":"com.apple.Terminal",\
        "appName":"Terminal","windowId":28219,"workspace":"1"}
        """

        // When decoding
        let event = try decode(json)

        // Then every field is captured
        expect(event) == .windowDetected(
            windowId: 28_219,
            workspace: "1",
            appBundleId: "com.apple.Terminal",
            appName: "Terminal"
        )
    }

    func testDecodesBindingTriggered() throws {
        // Given a binding-triggered payload
        let json = #"{"_event":"binding-triggered","binding":"ctrl-alt-right","mode":"main"}"#

        // When decoding
        let event = try decode(json)

        // Then the binding and mode are captured
        expect(event) == .bindingTriggered(mode: "main", binding: "ctrl-alt-right")
    }

    // MARK: - Absent Optional Fields

    func testDecodesFocusChangedWithoutWindowId() throws {
        // Given focus-changed emitted while no window is focused, so windowId is omitted
        let json = #"{"_event":"focus-changed","workspace":"3"}"#

        // When decoding
        let event = try decode(json)

        // Then the window id is nil rather than a decoding failure
        expect(event) == .focusChanged(windowId: nil, workspace: "3")
    }

    func testDecodesModeChangedWithoutMode() throws {
        // Given mode-changed emitted with no active mode, so mode is omitted
        let json = #"{"_event":"mode-changed"}"#

        // When decoding
        let event = try decode(json)

        // Then the mode is nil
        expect(event) == .modeChanged(mode: nil)
    }

    func testDecodesWindowDetectedWithOnlyWindowId() throws {
        // Given window-detected with every optional field omitted
        let json = #"{"_event":"window-detected","windowId":42}"#

        // When decoding
        let event = try decode(json)

        // Then only the required window id is populated
        expect(event) == .windowDetected(windowId: 42, workspace: nil, appBundleId: nil, appName: nil)
    }

    // MARK: - Error And Skip Paths

    func testReturnsNilForUnknownEventType() throws {
        // Given an event type this app does not know about
        let json = #"{"_event":"some-future-event","windowId":1}"#

        // When decoding
        let event = try decode(json)

        // Then it is skipped rather than throwing, so a newer AeroSpace cannot
        // break the stream
        expect(event).to(beNil())
    }

    func testThrowsWhenRequiredFieldIsMissing() {
        // Given focus-changed missing its required workspace field
        let json = #"{"_event":"focus-changed","windowId":7}"#

        // When decoding, then it throws a decoding error
        expect { try self.decode(json) }.to(throwError(errorType: AppError.self))
    }

    func testThrowsOnMalformedJson() {
        // Given a payload that is not valid JSON
        let json = "{not json"

        // When decoding, then it throws a decoding error
        expect { try self.decode(json) }.to(throwError(errorType: AppError.self))
    }

    // MARK: - Refresh Classification

    func testEventsThatChangeSpacesRequireRefresh() {
        // Given the events that can alter the spaces-and-windows model
        let events: [AeroSpaceEvent] = [
            .focusChanged(windowId: 1, workspace: "1"),
            .focusedMonitorChanged(workspace: "1", monitorId: 1),
            .focusedWorkspaceChanged(workspace: "2", previousWorkspace: "1"),
            .windowDetected(windowId: 1, workspace: "1", appBundleId: nil, appName: nil)
        ]

        // Then each requires a refresh
        for event in events {
            expect(event.requiresSpacesRefresh) == true
        }
    }

    func testInputOnlyEventsDoNotRequireRefresh() {
        // Given events that affect only AeroSpace's input handling
        let events: [AeroSpaceEvent] = [
            .modeChanged(mode: "main"),
            .bindingTriggered(mode: "main", binding: "alt-1")
        ]

        // Then neither triggers a refresh
        for event in events {
            expect(event.requiresSpacesRefresh) == false
        }
    }
}
