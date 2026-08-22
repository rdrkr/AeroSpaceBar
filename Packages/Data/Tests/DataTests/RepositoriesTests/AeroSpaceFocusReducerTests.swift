// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Data
import Domain
import Nimble
import XCTest

final class AeroSpaceFocusReducerTests: XCTestCase {
    func testMovesFocusWithoutFetchingAnotherSnapshot() {
        let spaces = [
            Space(id: "1", isFocused: true, windows: [makeWindow(id: 10, workspace: "1", isFocused: true)]),
            Space(id: "2", windows: [makeWindow(id: 20, workspace: "2")])
        ]

        let result = AeroSpaceFocusReducer.reduce(
            spaces: spaces,
            focusedWorkspace: "2",
            focusedWindowId: 20
        )

        expect(result[0].isFocused) == false
        expect(result[0].windows[0].isFocused) == false
        expect(result[1].isFocused) == true
        expect(result[1].windows[0].isFocused) == true
    }

    func testEmptyWorkspaceClearsWindowFocus() {
        let spaces = [
            Space(id: "1", isFocused: true, windows: [makeWindow(id: 10, workspace: "1", isFocused: true)]),
            Space(id: "2")
        ]

        let result = AeroSpaceFocusReducer.reduce(
            spaces: spaces,
            focusedWorkspace: "2",
            focusedWindowId: nil
        )

        expect(result[0].windows[0].isFocused) == false
        expect(result[1].isFocused) == true
    }

    private func makeWindow(id: Int, workspace: String, isFocused: Bool = false) -> Window {
        Window(
            id: id,
            title: "Window \(id)",
            appName: "Test",
            isFocused: isFocused,
            workspace: workspace
        )
    }
}
