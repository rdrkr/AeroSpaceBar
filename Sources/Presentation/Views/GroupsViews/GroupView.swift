// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that represents the group background for a set of menu bar applications.
struct GroupView: View {
    /// The group configuration containing styling and range information.
    let group: Domain.Group

    /// The complete list of menu bar applications from which to select group members.
    let menuBarApps: [MenuBarApp]

    /// The appearance mode determining which styling properties to use.
    let appearanceMode: GroupsAppearanceMode

    /// The visual configuration for global groups appearance mode.
    let globalVisualConfiguration: VisualContainer

    /// The visual configuration for match spaces appearance mode.
    let spaceVisualConfiguration: VisualContainer

    /// The apps in this group that are currently visible (based on group range)
    private var groupApps: [MenuBarApp] {
        let actualEndIndex = group.getEndIndex(menuBarAppsCount: menuBarApps.count)
        guard group.startIndex > 0, actualEndIndex >= group.startIndex, actualEndIndex <= menuBarApps.count else {
            return []
        }

        let range = group.startIndex ... actualEndIndex
        return Array(menuBarApps.dropFirst(range.lowerBound - 1).prefix(range.count))
    }

    // MARK: - Appearance Properties

    /// The visual configuration based on the current appearance mode
    private var currentVisualConfiguration: VisualContainer {
        switch appearanceMode {
        case .perApp:
            // For per-app mode, use the group's visual configuration
            group.visualConfig

        case .allGroups:
            globalVisualConfiguration

        case .matchSpaces:
            spaceVisualConfiguration

        @unknown default:
            // For unknown cases, use the group's visual configuration as fallback
            group.visualConfig
        }
    }

    /// The background tint color based on the current appearance mode
    private var backgroundTintColor: Color {
        currentVisualConfiguration.backgroundTintColor
    }

    /// The background opacity based on the current appearance mode
    private var backgroundOpacity: Double {
        currentVisualConfiguration.backgroundOpacity
    }

    /// The background blur radius based on the current appearance mode
    private var backgroundBlurRadius: Double {
        currentVisualConfiguration.backgroundBlurRadius
    }

    /// The border color based on the current appearance mode
    private var borderColor: Color {
        currentVisualConfiguration.borderTintColor
    }

    /// The border opacity based on the current appearance mode
    private var borderOpacity: Double {
        currentVisualConfiguration.borderOpacity
    }

    /// The border width based on the current appearance mode
    private var borderWidth: Double {
        currentVisualConfiguration.borderWidth
    }

    /// The corner radius based on the current appearance mode
    private var cornerRadius: Double {
        currentVisualConfiguration.cornerRadius
    }

    /// The combined frame that encompasses all apps in this group
    private var groupFrame: CGRect {
        let apps = groupApps
        guard !apps.isEmpty else { return .zero }

        let minX = apps.map(\.frame.minX).min() ?? 0
        let maxX = apps.map(\.frame.maxX).max() ?? 0
        let minY = apps.map(\.frame.minY).min() ?? 0
        let maxY = apps.map(\.frame.maxY).max() ?? 0

        let fullWidth = maxX - minX
        let fullHeight = maxY - minY
        let reduceWidth = fullWidth - ConfigurationDefaults.widgetSpacing
        let reducedHeight = ConfigurationDefaults.windowIconSize + (ConfigurationDefaults.menuBarVerticalPadding * 2)
        let horizontalMargin = (fullWidth - reduceWidth) / 2
        let verticalMargin = (fullHeight - reducedHeight) / 2

        return CGRect(
            x: minX + horizontalMargin,
            y: minY + verticalMargin,
            width: reduceWidth,
            height: reducedHeight
        )
    }

    var body: some View {
        Group {
            Color.clear
                .background(
                    backgroundTintColor
                        .opacity(backgroundOpacity)
                        .blur(radius: backgroundBlurRadius)
                )
                .cornerRadius(cornerRadius)
                .frame(width: groupFrame.width, height: groupFrame.height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            borderColor.opacity(borderOpacity),
                            lineWidth: borderWidth
                        )
                        .frame(
                            width: groupFrame.width + borderWidth,
                            height: groupFrame.height + borderWidth
                        )
                )
                .position(
                    x: groupFrame.midX,
                    y: groupFrame.midY
                )
                .standardShadow()
        }
        .animation(.themeEaseInOutFast, value: groupFrame)
    }
}
