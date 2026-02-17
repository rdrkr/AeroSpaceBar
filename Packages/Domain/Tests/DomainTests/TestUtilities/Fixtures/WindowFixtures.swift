// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation
import SwiftUI

/// Test fixtures for Window entities.
///
/// This provides reusable, well-defined test data for Window entities
/// to ensure consistent and predictable testing.
public enum WindowFixtures {
    /// A Safari browser window
    public static let safari = Window(
        id: 1_001,
        title: "Safari - Google",
        appName: "Safari",
        isFocused: false,
        workspace: "1",
        appIcon: nil
    )

    /// A focused Safari window
    public static let safariFocused = Window(
        id: 1_001,
        title: "Safari - Google",
        appName: "Safari",
        isFocused: true,
        workspace: "1",
        appIcon: nil
    )

    /// A VS Code editor window
    public static let vscode = Window(
        id: 1_002,
        title: "main.swift - VSCode",
        appName: "Code",
        isFocused: false,
        workspace: "2",
        appIcon: nil
    )

    /// A focused VS Code window
    public static let vscodeFocused = Window(
        id: 1_002,
        title: "main.swift - VSCode",
        appName: "Code",
        isFocused: true,
        workspace: "2",
        appIcon: nil
    )

    /// A Terminal window
    public static let terminal = Window(
        id: 1_003,
        title: "Terminal - bash",
        appName: "Terminal",
        isFocused: false,
        workspace: "3",
        appIcon: nil
    )

    /// A focused Terminal window
    public static let terminalFocused = Window(
        id: 1_003,
        title: "Terminal - bash",
        appName: "Terminal",
        isFocused: true,
        workspace: "3",
        appIcon: nil
    )

    /// A Slack window
    public static let slack = Window(
        id: 1_004,
        title: "Slack - Team Chat",
        appName: "Slack",
        isFocused: false,
        workspace: "4",
        appIcon: nil
    )

    /// A Chrome browser window
    public static let chrome = Window(
        id: 1_005,
        title: "Chrome - Stack Overflow",
        appName: "Google Chrome",
        isFocused: false,
        workspace: "1",
        appIcon: nil
    )

    /// A window with custom color properties
    public static let withCustomColors = Window(
        id: 1_006,
        title: "Custom Window",
        appName: "TestApp",
        isFocused: false,
        workspace: "1",
        appIcon: nil,
        colorProperties: ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .black,
            foregroundColor: .white
        )
    )

    /// Creates a window with a specific ID
    public static func withId(_ id: Int) -> Domain.Window {
        Window(
            id: id,
            title: "Window \(id)",
            appName: "TestApp",
            isFocused: false,
            workspace: "1",
            appIcon: nil
        )
    }

    /// Creates a focused window with a specific ID
    public static func focusedWithId(_ id: Int) -> Domain.Window {
        Domain.Window(
            id: id,
            title: "Window \(id)",
            appName: "TestApp",
            isFocused: true,
            workspace: "1",
            appIcon: nil
        )
    }

    /// Creates a window for a specific workspace
    public static func inWorkspace(_ workspace: String) -> Domain.Window {
        Domain.Window(
            id: Int.random(in: 1_000 ... 9_999),
            title: "Window in \(workspace)",
            appName: "TestApp",
            isFocused: false,
            workspace: workspace,
            appIcon: nil
        )
    }

    /// A minimized window
    public static let minimized = Window(
        id: 1_007,
        title: "Minimized Window",
        appName: "TestApp",
        isFocused: false,
        workspace: "1",
        appIcon: nil
    )

    /// A floating window
    public static let floating = Window(
        id: 1_008,
        title: "Floating Window",
        appName: "TestApp",
        isFocused: false,
        workspace: "1",
        appIcon: nil
    )

    /// Creates an array of windows numbered from startId
    public static func array(count: Int, startId: Int = 1_000, workspace: String = "1") -> [Domain.Window] {
        (0 ..< count).map { i in
            Domain.Window(
                id: startId + i,
                title: "Window \(startId + i)",
                appName: "TestApp",
                isFocused: false,
                workspace: workspace,
                appIcon: nil
            )
        }
    }
}
