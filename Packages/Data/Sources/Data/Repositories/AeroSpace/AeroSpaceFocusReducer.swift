// Copyright (c) 2026 Jakub Kubiak.

import Domain
import Foundation

/// Applies AeroSpace focus events to the last complete snapshot without waiting
/// for another set of CLI queries.
internal enum AeroSpaceFocusReducer {
    internal static func reduce(
        spaces: [Space],
        focusedWorkspace: String?,
        focusedWindowId: UInt32?
    ) -> [Space] {
        guard focusedWorkspace != nil || focusedWindowId != nil else { return spaces }

        return spaces.map { space in
            var updatedSpace = space

            if let focusedWorkspace {
                updatedSpace.isFocused = space.id == focusedWorkspace
            }

            updatedSpace.windows = space.windows.map { window in
                var updatedWindow = window
                updatedWindow.isFocused = focusedWindowId.map { window.id == Int($0) } ?? false
                return updatedWindow
            }

            return updatedSpace
        }
    }

    /// Replaces the cached title for one window while preserving its icon,
    /// focus state, and visual configuration.
    internal static func replacingWindowTitle(
        in spaces: [Space],
        windowId: Int,
        title: String
    ) -> [Space] {
        spaces.map { space in
            var updatedSpace = space
            updatedSpace.windows = space.windows.map { window in
                guard window.id == windowId else { return window }

                var updatedWindow = window
                updatedWindow.title = title
                return updatedWindow
            }
            return updatedSpace
        }
    }
}
