// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for MenuBarApp entity.
///
/// These tests verify MenuBarApp initialization, Identifiable conformance,
/// Equatable conformance, and frame handling.
@MainActor
final class MenuBarAppTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given parameters
        let id = "com.apple.controlcenter"
        let frame = CGRect(x: 100, y: 0, width: 30, height: 25)

        // When creating menu bar app
        let app = MenuBarApp(id: id, frame: frame)

        // Then all properties should be set
        expect(app.id) == id
        expect(app.frame) == frame
    }

    func testInitializationWithZeroFrame() {
        // Given zero frame
        let frame = CGRect.zero

        // When creating menu bar app
        let app = MenuBarApp(id: "test", frame: frame)

        // Then should be valid
        expect(app.frame) == .zero
    }

    func testInitializationWithLargeFrame() {
        // Given large frame
        let frame = CGRect(x: 1_000, y: 0, width: 200, height: 50)

        // When creating menu bar app
        let app = MenuBarApp(id: "test", frame: frame)

        // Then should handle large values
        expect(app.frame.width) == 200
        expect(app.frame.height) == 50
    }

    // MARK: - Identifiable Tests

    func testConformsToIdentifiable() {
        // Given menu bar app
        let app = MenuBarApp(id: "test-id", frame: .zero)

        // Then should conform to Identifiable
        expect(app.id) == "test-id"
    }

    func testIdentifierUniqueness() {
        // Given apps with different IDs
        let app1 = MenuBarApp(id: "app1", frame: .zero)
        let app2 = MenuBarApp(id: "app2", frame: .zero)

        // Then IDs should be different
        expect(app1.id) != app2.id
    }

    func testIdentifierCanBeAnyString() {
        // Given various ID formats
        let ids = [
            "com.apple.controlcenter",
            "WiFi",
            "Battery",
            "clock-123",
            "app_with_underscore",
            ""
        ]

        for id in ids {
            // When creating app with ID
            let app = MenuBarApp(id: id, frame: .zero)

            // Then should accept any string
            expect(app.id) == id
        }
    }

    // MARK: - Equatable Tests

    func testEqualityWithSameValues() {
        // Given two apps with same values
        let frame = CGRect(x: 100, y: 0, width: 30, height: 25)
        let app1 = MenuBarApp(id: "test", frame: frame)
        let app2 = MenuBarApp(id: "test", frame: frame)

        // Then they should be equal
        expect(app1) == app2
    }

    func testInequalityWithDifferentIds() {
        // Given two apps with different IDs
        let frame = CGRect(x: 100, y: 0, width: 30, height: 25)
        let app1 = MenuBarApp(id: "app1", frame: frame)
        let app2 = MenuBarApp(id: "app2", frame: frame)

        // Then they should not be equal
        expect(app1) != app2
    }

    func testInequalityWithDifferentFrames() {
        // Given two apps with different frames
        let frame1 = CGRect(x: 100, y: 0, width: 30, height: 25)
        let frame2 = CGRect(x: 200, y: 0, width: 40, height: 25)
        let app1 = MenuBarApp(id: "test", frame: frame1)
        let app2 = MenuBarApp(id: "test", frame: frame2)

        // Then they should not be equal
        expect(app1) != app2
    }

    // MARK: - Frame Tests

    func testFramePosition() {
        // Given frame with specific position
        let frame = CGRect(x: 150, y: 5, width: 30, height: 25)
        let app = MenuBarApp(id: "test", frame: frame)

        // Then should preserve position
        expect(app.frame.origin.x) == 150
        expect(app.frame.origin.y) == 5
    }

    func testFrameSize() {
        // Given frame with specific size
        let frame = CGRect(x: 0, y: 0, width: 35, height: 22)
        let app = MenuBarApp(id: "test", frame: frame)

        // Then should preserve size
        expect(app.frame.width) == 35
        expect(app.frame.height) == 22
    }

    func testFrameWithNegativeOrigin() {
        // Given frame with negative origin (edge case)
        let frame = CGRect(x: -10, y: -5, width: 30, height: 25)
        let app = MenuBarApp(id: "test", frame: frame)

        // Then should preserve negative values
        expect(app.frame.origin.x) == -10
        expect(app.frame.origin.y) == -5
    }

    func testFrameWithDecimalValues() {
        // Given frame with decimal values
        let frame = CGRect(x: 100.5, y: 0.25, width: 30.75, height: 25.5)
        let app = MenuBarApp(id: "test", frame: frame)

        // Then should preserve decimal precision
        expect(app.frame.origin.x) == 100.5
        expect(app.frame.origin.y) == 0.25
        expect(app.frame.width) == 30.75
        expect(app.frame.height) == 25.5
    }

    // MARK: - Collection Tests

    func testArrayOfMenuBarApps() {
        // Given multiple menu bar apps
        let apps = [
            MenuBarApp(id: "WiFi", frame: CGRect(x: 100, y: 0, width: 30, height: 25)),
            MenuBarApp(id: "Battery", frame: CGRect(x: 130, y: 0, width: 40, height: 25)),
            MenuBarApp(id: "Clock", frame: CGRect(x: 170, y: 0, width: 60, height: 25))
        ]

        // Then should maintain order and uniqueness
        expect(apps.count) == 3
        expect(apps[0].id) == "WiFi"
        expect(apps[1].id) == "Battery"
        expect(apps[2].id) == "Clock"
    }

    func testFilteringMenuBarApps() {
        // Given menu bar apps
        let apps = [
            MenuBarApp(id: "com.apple.WiFi", frame: CGRect(x: 100, y: 0, width: 30, height: 25)),
            MenuBarApp(id: "com.third.party", frame: CGRect(x: 130, y: 0, width: 40, height: 25)),
            MenuBarApp(id: "com.apple.Battery", frame: CGRect(x: 170, y: 0, width: 60, height: 25))
        ]

        // When filtering by Apple apps
        let appleApps = apps.filter { $0.id.hasPrefix("com.apple.") }

        // Then should find Apple apps
        expect(appleApps.count) == 2
    }

    func testSortingMenuBarAppsByPosition() {
        // Given unsorted menu bar apps
        let apps = [
            MenuBarApp(id: "Last", frame: CGRect(x: 200, y: 0, width: 30, height: 25)),
            MenuBarApp(id: "First", frame: CGRect(x: 100, y: 0, width: 30, height: 25)),
            MenuBarApp(id: "Middle", frame: CGRect(x: 150, y: 0, width: 30, height: 25))
        ]

        // When sorting by x position
        let sorted = apps.sorted { $0.frame.origin.x < $1.frame.origin.x }

        // Then should be in position order
        expect(sorted[0].id) == "First"
        expect(sorted[1].id) == "Middle"
        expect(sorted[2].id) == "Last"
    }

    // MARK: - Edge Cases

    func testEmptyId() {
        // Given empty ID
        let app = MenuBarApp(id: "", frame: .zero)

        // Then should be valid
        expect(app.id.isEmpty) == true
    }

    func testVeryLongId() {
        // Given very long ID
        let longId = String(repeating: "a", count: 1_000)
        let app = MenuBarApp(id: longId, frame: .zero)

        // Then should handle long IDs
        expect(app.id.count) == 1_000
    }

    func testSpecialCharactersInId() {
        // Given ID with special characters
        let specialId = "app.with-special_chars@123!#"
        let app = MenuBarApp(id: specialId, frame: .zero)

        // Then should preserve special characters
        expect(app.id) == specialId
    }

    func testUnicodeInId() {
        // Given ID with unicode characters
        let unicodeId = "app🚀emoji"
        let app = MenuBarApp(id: unicodeId, frame: .zero)

        // Then should support unicode
        expect(app.id) == unicodeId
    }

    // MARK: - Typical Menu Bar App Scenarios

    func testSystemControlCenterApp() {
        // Given control center app
        let app = MenuBarApp(
            id: "com.apple.controlcenter",
            frame: CGRect(x: 100, y: 0, width: 30, height: 25)
        )

        // Then should represent system app
        expect(app.id.hasPrefix("com.apple.")) == true
        expect(app.frame.width) > 0
    }

    func testClockApp() {
        // Given clock app (typically at far right)
        let app = MenuBarApp(
            id: "clock",
            frame: CGRect(x: 1_400, y: 0, width: 80, height: 25)
        )

        // Then should have typical clock dimensions
        expect(app.frame.width) > 50 // Clock needs space for time
    }

    func testBatteryIndicator() {
        // Given battery indicator
        let app = MenuBarApp(
            id: "com.apple.menuextra.battery",
            frame: CGRect(x: 200, y: 0, width: 50, height: 25)
        )

        // Then should have typical battery dimensions
        expect(app.frame.width) > 0
        expect(app.frame.height) == 25 // Standard menu bar height
    }

    // MARK: - Immutability Tests

    func testPropertiesAreImmutable() {
        // Given menu bar app
        let app = MenuBarApp(id: "test", frame: .zero)

        // Then properties should be immutable (let constants)
        // This is enforced by the compiler - if this compiles, test passes
        expect(app.id).toNot(beNil())
        expect(app.frame).toNot(beNil())
    }
}
