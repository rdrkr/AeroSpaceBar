// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that displays the desktop wallpaper as background for the spaces.
///
/// This view handles the wallpaper display logic, including proper cropping
/// and positioning to create an immersive menu bar experience.
struct WallpaperBackgroundView: View {
    /// The wallpaper image to display
    let wallpaper: NSImage

    // MARK: - Computed Properties

    private var screenWidth: Double {
        wallpaper.size.width
    }

    private var screenHeight: Double {
        wallpaper.size.height
    }

    // MARK: - Body

    var body: some View {
        Image(nsImage: wallpaper)
            .frame(
                width: (screenWidth / 2) - ConfigurationDefaults.menuBarHorizontalPadding,
                height: screenHeight
            )
            .offset(
                x: (screenWidth / 4) - (ConfigurationDefaults.menuBarHorizontalPadding / 2),
                y: 0
            )
            .clipped()
            .tag("spaces-wallpaper-background")
    }
}

#Preview {
    // swiftlint:disable object_literal
    if let wallpaper = NSImage(named: "AppIcon") {
        WallpaperBackgroundView(
            wallpaper: wallpaper
        )
        .padding()
    } else {
        Text("No wallpaper available for preview")
            .foregroundColor(.secondary)
    }
    // swiftlint:enable object_literal
}
