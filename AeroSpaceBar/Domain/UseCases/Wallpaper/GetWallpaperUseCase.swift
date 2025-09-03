// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Foundation

/// Use case for retrieving desktop wallpaper.
///
/// This use case captures the current desktop wallpaper dynamically instead of
/// using a user-selected image. It belongs to the domain layer and coordinates
/// between the presentation and data layers. Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
final class GetWallpaperUseCase {
    /// The desktop wallpaper gateway for capturing wallpaper.
    private let desktopWallpaperGateway: DesktopWallpaperGateway

    /// Initializes the use case with the desktop wallpaper gateway.
    /// - Parameter desktopWallpaperRepository: The gateway for capturing desktop wallpaper
    init(desktopWallpaperGateway: DesktopWallpaperGateway) {
        self.desktopWallpaperGateway = desktopWallpaperGateway
    }

    /// Returns a publisher that emits updates to the wallpaper image.
    /// - Returns: A publisher that emits wallpaper image updates
    func execute() -> AnyPublisher<NSImage?, Never> {
        desktopWallpaperGateway.wallpaperPublisher
    }
}
