// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import SwiftUI

/// Use case for retrieving the menu bar height configuration.
///
/// This use case encapsulates the business logic for retrieving the menu bar height
/// from the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
final class GetMenuBarHeightUseCase {
    /// The desktop wallpaper gateway for capturing wallpaper.
    private let desktopWallpaperGateway: DesktopWallpaperGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter desktopWallpaperGateway: The gateway for accessing desktop wallpaper data
    init(desktopWallpaperGateway: DesktopWallpaperGateway) {
        self.desktopWallpaperGateway = desktopWallpaperGateway
    }

    /// Executes the use case to get the menu bar height setting as a publisher.
    /// - Returns: A publisher that emits menu bar height values
    func execute() -> AnyPublisher<CGFloat, Never> {
        desktopWallpaperGateway.menuBarHeightPublisher
    }
}
