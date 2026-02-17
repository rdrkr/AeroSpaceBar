// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation
import SwiftUI

/// Test fixtures for Space entities.
///
/// This provides reusable, well-defined test data for Space entities
/// to ensure consistent and predictable testing.
public enum SpaceFixtures {
    /// A basic space with minimal configuration
    public static let basic = Space(
        id: "1",
        isFocused: false,
        windows: []
    )

    /// A focused space
    public static let focused = Space(
        id: "2",
        isFocused: true,
        windows: []
    )

    /// A space with multiple windows
    public static let withWindows = Space(
        id: "3",
        isFocused: false,
        windows: [
            WindowFixtures.safari,
            WindowFixtures.vscode,
            WindowFixtures.terminal
        ]
    )

    /// A focused space with windows
    public static let focusedWithWindows = Space(
        id: "4",
        isFocused: true,
        windows: [
            WindowFixtures.safari,
            WindowFixtures.terminal
        ]
    )

    /// A space with custom color properties
    public static let withCustomColors = Space(
        id: "5",
        isFocused: false,
        windows: [],
        colorProperties: ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .black,
            foregroundColor: .white
        )
    )

    /// Creates a space with a specific ID
    public static func withId(_ id: String) -> Space {
        Space(id: id, isFocused: false, windows: [])
    }

    /// Creates a focused space with a specific ID
    public static func focusedWithId(_ id: String) -> Space {
        Space(id: id, isFocused: true, windows: [])
    }

    /// Creates a space with specific windows
    public static func withWindows(_ windows: [Domain.Window]) -> Space {
        Space(id: "test", isFocused: false, windows: windows)
    }

    /// Creates an array of spaces numbered from 1 to count
    public static func array(count: Int, focused: String? = nil) -> [Space] {
        (1 ... count).map { i in
            let id = String(i)
            return Space(
                id: id,
                isFocused: focused == id,
                windows: []
            )
        }
    }
}
