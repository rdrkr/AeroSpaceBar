// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that represents the group background for a set of menu bar applications.
struct GroupView: View {
    let group: GroupConfiguration
    let menuBarApps: [MenuBarApp]
    let animationDuration: Double
    let widgetSpacing: CGFloat

    /// The apps in this group that are currently visible (based on group range)
    private var groupApps: [MenuBarApp] {
        let actualEndIndex = group.getEndIndex(menuBarAppsCount: menuBarApps.count)
        guard group.startIndex > 0, actualEndIndex >= group.startIndex, actualEndIndex <= menuBarApps.count else {
            return []
        }

        let range = group.startIndex ... actualEndIndex
        return Array(menuBarApps.dropFirst(range.lowerBound - 1).prefix(range.count))
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
                RoundedRectangle(cornerRadius: group.cornerRadius, style: .continuous)
                    .fill(group.backgroundTintColor.opacity(group.backgroundOpacity))
                    .background(
                        group.backgroundTintColor
                            .opacity(group.backgroundOpacity)
                            .blur(radius: group.backgroundBlurRadius)
                            .clipShape(RoundedRectangle(cornerRadius: group.cornerRadius, style: .continuous))
                    )

                // Border
                RoundedRectangle(cornerRadius: group.cornerRadius, style: .continuous)
                    .stroke(group.borderColor.opacity(group.borderOpacity), lineWidth: CGFloat(group.borderWidth))
            }
            .frame(width: groupFrame.width, height: groupFrame.height)
            .clipShape(RoundedRectangle(cornerRadius: group.cornerRadius, style: .continuous))
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
