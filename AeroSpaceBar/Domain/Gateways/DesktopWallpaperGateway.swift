// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Foundation

/// Protocol defining the interface for desktop wallpaper operations.
///
/// This protocol provides a contract for repositories that manage desktop wallpaper capture,
/// allowing for easy testing and dependency injection. It belongs to the domain layer
/// and defines the business requirements for wallpaper operations.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
protocol DesktopWallpaperGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits wallpaper image updates.
    var wallpaperPublisher: AnyPublisher<NSImage?, Never> { get }

    /// Publisher that emits menu bar height updates.
    var menuBarHeightPublisher: AnyPublisher<CGFloat, Never> { get }
}
