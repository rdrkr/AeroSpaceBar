// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that represents the group background for a set of menu bar applications.
struct GroupView: View {
    let group: GroupConfiguration
    let menuBarApps: [MenuBarApp]
    let animationDuration: Double
    let widgetSpacing: Double
    let appearanceMode: GroupsAppearanceMode
    let globalBackgroundTintColor: Color
    let globalBackgroundOpacity: Double
    let globalBackgroundBlurRadius: Double
    let globalBorderColor: Color
    let globalBorderOpacity: Double
    let globalBorderWidth: Double
    let globalCornerRadius: Double
    let spaceBackgroundTintColor: Color
    let spaceBackgroundOpacity: Double
    let spaceBackgroundBlurRadius: Double
    let spaceBorderTintColor: Color
    let spaceBorderOpacity: Double
    let spaceBorderWidth: Double
    let spaceCornerRadius: Double

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

    /// The background tint color based on the current appearance mode
    private var backgroundTintColor: Color {
        switch appearanceMode {
        case .perApp:
            group.backgroundTintColor
        case .allGroups:
            globalBackgroundTintColor
        case .matchSpaces:
            spaceBackgroundTintColor
        @unknown default:
            group.backgroundTintColor
        }
    }

    /// The background opacity based on the current appearance mode
    private var backgroundOpacity: Double {
        switch appearanceMode {
        case .perApp:
            group.backgroundOpacity
        case .allGroups:
            globalBackgroundOpacity
        case .matchSpaces:
            spaceBackgroundOpacity
        @unknown default:
            group.backgroundOpacity
        }
    }

    /// The background blur radius based on the current appearance mode
    private var backgroundBlurRadius: Double {
        switch appearanceMode {
        case .perApp:
            group.backgroundBlurRadius
        case .allGroups:
            globalBackgroundBlurRadius
        case .matchSpaces:
            spaceBackgroundBlurRadius
        @unknown default:
            group.backgroundBlurRadius
        }
    }

    /// The border color based on the current appearance mode
    private var borderColor: Color {
        switch appearanceMode {
        case .perApp:
            group.borderColor
        case .allGroups:
            globalBorderColor
        case .matchSpaces:
            spaceBorderTintColor
        @unknown default:
            group.borderColor
        }
    }

    /// The border opacity based on the current appearance mode
    private var borderOpacity: Double {
        switch appearanceMode {
        case .perApp:
            group.borderOpacity
        case .allGroups:
            globalBorderOpacity
        case .matchSpaces:
            spaceBorderOpacity
        @unknown default:
            group.borderOpacity
        }
    }

    /// The border width based on the current appearance mode
    private var borderWidth: Double {
        switch appearanceMode {
        case .perApp:
            Double(group.borderWidth)
        case .allGroups:
            Double(globalBorderWidth)
        case .matchSpaces:
            spaceBorderWidth
        @unknown default:
            Double(group.borderWidth)
        }
    }

    /// The corner radius based on the current appearance mode
    private var cornerRadius: Double {
        switch appearanceMode {
        case .perApp:
            group.cornerRadius
        case .allGroups:
            globalCornerRadius
        case .matchSpaces:
            spaceCornerRadius
        @unknown default:
            group.cornerRadius
        }
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
        let reduceWidth = fullWidth - widgetSpacing
        let reducedHeight = fullHeight * 0.62 // 62% of original height
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
        if !groupApps.isEmpty {
            ZStack {
                // Background with blur
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        backgroundTintColor.opacity(backgroundOpacity)
                    )
                    .blur(radius: backgroundBlurRadius)

                // Border
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor.opacity(borderOpacity), lineWidth: borderWidth)
            }
            .frame(width: groupFrame.width, height: groupFrame.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .position(
                x: groupFrame.midX,
                y: groupFrame.midY
            )
            .standardShadow()
            .blurReplaceTransition()
            .smoothAnimation(duration: animationDuration)
        }
    }
}
