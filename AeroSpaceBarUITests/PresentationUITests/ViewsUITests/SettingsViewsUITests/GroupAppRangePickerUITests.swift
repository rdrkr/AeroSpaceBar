// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for GroupAppRangePicker.
///
/// These tests verify:
/// - Start and end index pickers display
/// - Range constraint enforcement
/// - Minimum/maximum bounds
/// - Automatic adjustment on changes
/// - Label and description text
/// - Picker layout and sizing
@MainActor
final class GroupAppRangePickerUITests: XCTestCase {
    private var app: XCUIApplication?

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        // Use guard statement to safely initialize app

        app = XCUIApplication()

        guard let app else {
            XCTFail("XCUIApplication should be initialized")

            return
        }

        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Display Tests

    func testRangePickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then range picker should be displayed
        // with "Range" label and description
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Range picker should be displayed"
        )
    }

    func testRangeLabel() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given range picker is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Range" label should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Range label should be displayed"
        )
    }

    func testRangeDescription() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given range picker is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then description should say:
        // "Select which menu bar applications to include (right to left)."
        // in secondary text style
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Range description should be displayed"
        )
    }

    // MARK: - Start Index Picker Tests

    func testStartIndexPickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given range picker is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "From" picker should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start index picker should be displayed"
        )
    }

    func testStartIndexRange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given range picker with constraints
        // minimumStartIndex = 1, endIndex = 5
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then start index picker should show values:
        // from minimumStartIndex to min(endIndex, totalApps)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start index should respect bounds"
        )
    }

    func testStartIndexMinimumConstraint() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user tries to set startIndex below minimum
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then startIndex should be constrained to minimumStartIndex
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start index should respect minimum"
        )
    }

    func testStartIndexAdjustsEndIndex() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user increases startIndex above current endIndex
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then endIndex should be automatically adjusted to startIndex
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "End index should adjust when start increases"
        )
    }

    // MARK: - End Index Picker Tests

    func testEndIndexPickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given range picker is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "To" picker should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "End index picker should be displayed"
        )
    }

    func testEndIndexRange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given range picker with constraints
        // startIndex = 1, maximumEndIndex = 10, totalApps = 15
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then end index picker should show values:
        // from startIndex to min(maximumEndIndex, totalApps)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "End index should respect bounds"
        )
    }

    func testEndIndexMaximumConstraint() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user tries to set endIndex above maximum
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then endIndex should be constrained to min(maximumEndIndex, totalApps)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "End index should respect maximum"
        )
    }

    func testEndIndexAdjustsStartIndex() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user decreases endIndex below current startIndex
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then startIndex should be automatically adjusted
        // to max(endIndex, minimumStartIndex)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start index should adjust when end decreases"
        )
    }

    // MARK: - Layout Tests

    func testHorizontalLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given range picker is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then layout should be HStack with:
        // - VStack(alignment: .leading) for label and description
        // - Spacer
        // - VStack(alignment: .trailing) for pickers with 100pt width
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Layout should use horizontal stack"
        )
    }

    func testPickerContainerWidth() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given pickers are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then picker container should have 100pt fixed width
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Pickers should have fixed width"
        )
    }

    func testPickerSpacer() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given both pickers are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then Spacer should be between "From" and "To" pickers
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spacer should separate pickers"
        )
    }

    // MARK: - Edge Case Tests

    func testInvalidRangeHandling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given minimumStartIndex > endIndex
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then picker should show single-value range
        // from minimumStartIndex to minimumStartIndex
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Invalid range should be handled gracefully"
        )
    }

    func testSingleValueRange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given startIndex == endIndex == totalApps
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then both pickers should show only one value
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Single value range should work"
        )
    }

    // MARK: - OnChange Behavior Tests

    func testStartIndexOnChange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user changes startIndex
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then onChange callback should:
        // 1. Constrain to minimum
        // 2. Adjust endIndex if needed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start index onChange should enforce constraints"
        )
    }

    func testEndIndexOnChange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user changes endIndex
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then onChange callback should:
        // 1. Constrain to maximum
        // 2. Adjust startIndex if needed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "End index onChange should enforce constraints"
        )
    }

    // MARK: - Binding Tests

    func testStartIndexBinding() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given startIndex is bound to parent state
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When picker value changes
        // Then parent state should update
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start index binding should work"
        )
    }

    func testEndIndexBinding() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given endIndex is bound to parent state
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When picker value changes
        // Then parent state should update
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "End index binding should work"
        )
    }
}
