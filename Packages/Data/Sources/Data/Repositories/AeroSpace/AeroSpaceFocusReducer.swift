// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

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
}
