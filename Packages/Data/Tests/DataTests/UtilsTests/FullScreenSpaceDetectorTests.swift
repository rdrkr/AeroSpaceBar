// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Data
import Nimble
import XCTest

/// Tests for `FullScreenSpaceDetector`.
final class FullScreenSpaceDetectorTests: XCTestCase {
    /// The UUID of the display under test.
    private let displayUUID = "37D8832A-2D66-02CA-B9F7-8F30A301B230"

    /// The UUID of another connected display.
    private let otherDisplayUUID = "5C1D0B9E-4C3B-4A1E-9F0A-2B7C6D8E9F10"

    /// The Space type the window server reports for a regular desktop Space.
    private let desktopSpaceType = 0

    /// A display showing a fullscreen Space is reported as fullscreen.
    func testReportsFullScreenSpaceOnDisplay() {
        let spaces = [entry(identifier: displayUUID, type: FullScreenSpaceDetector.Key.fullScreenSpaceType)]

        expect(FullScreenSpaceDetector.isShowingFullScreenSpace(displayUUID: self.displayUUID, in: spaces)) == true
    }

    /// A display showing a regular desktop Space is not reported as fullscreen.
    func testReportsDesktopSpaceAsNotFullScreen() {
        let spaces = [entry(identifier: displayUUID, type: desktopSpaceType)]

        expect(FullScreenSpaceDetector.isShowingFullScreenSpace(displayUUID: self.displayUUID, in: spaces)) == false
    }

    /// A fullscreen Space on another display does not hide the menu bar of this display.
    func testIgnoresFullScreenSpaceOnOtherDisplay() {
        let spaces = [
            entry(identifier: otherDisplayUUID, type: FullScreenSpaceDetector.Key.fullScreenSpaceType),
            entry(identifier: displayUUID, type: desktopSpaceType)
        ]

        expect(FullScreenSpaceDetector.isShowingFullScreenSpace(displayUUID: self.displayUUID, in: spaces)) == false
    }

    /// Display UUIDs are matched regardless of letter case.
    func testMatchesDisplayUUIDCaseInsensitively() {
        let spaces = [
            entry(identifier: displayUUID.lowercased(), type: FullScreenSpaceDetector.Key.fullScreenSpaceType)
        ]

        expect(FullScreenSpaceDetector.isShowingFullScreenSpace(displayUUID: self.displayUUID, in: spaces)) == true
    }

    /// Without separate Spaces per display, the single main entry applies to every display.
    func testMainEntryAppliesWhenDisplaysShareSpaces() {
        let spaces = [
            entry(
                identifier: FullScreenSpaceDetector.Key.mainDisplayIdentifier,
                type: FullScreenSpaceDetector.Key.fullScreenSpaceType
            )
        ]

        expect(FullScreenSpaceDetector.isShowingFullScreenSpace(displayUUID: self.displayUUID, in: spaces)) == true
    }

    /// Missing or malformed window server data is treated as not fullscreen.
    func testTreatsMissingDataAsNotFullScreen() {
        let malformed: [[String: Any]] = [[FullScreenSpaceDetector.Key.displayIdentifier: displayUUID]]

        expect(FullScreenSpaceDetector.isShowingFullScreenSpace(displayUUID: self.displayUUID, in: [])) == false
        expect(FullScreenSpaceDetector.isShowingFullScreenSpace(displayUUID: self.displayUUID, in: malformed)) == false
    }

    /// Builds one managed display spaces entry as the window server reports it.
    /// - Parameters:
    ///   - identifier: The display identifier.
    ///   - type: The type of the display's current Space.
    /// - Returns: The entry dictionary.
    private func entry(identifier: String, type: Int) -> [String: Any] {
        [
            FullScreenSpaceDetector.Key.displayIdentifier: identifier,
            FullScreenSpaceDetector.Key.currentSpace: [FullScreenSpaceDetector.Key.spaceType: type]
        ]
    }
}
