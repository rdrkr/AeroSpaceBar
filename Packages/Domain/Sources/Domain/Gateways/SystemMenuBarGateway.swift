// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Foundation

/// Protocol defining the interface for system menu bar operations.
///
/// This protocol provides a contract for repositories that manage desktop wallpaper capture,
/// menu bar height tracking, and menu bar visibility detection. It belongs to the domain layer
/// and defines the business requirements for system menu bar operations.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
public protocol SystemMenuBarGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits wallpaper image updates.
    var wallpaperPublisher: AnyPublisher<NSImage?, Never> { get }

    /// Publisher that emits menu bar height updates.
    var menuBarHeightPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits system menu bar visibility changes.
    /// Emits `true` when the menu bar is visible, `false` when hidden.
    var menuBarVisibilityPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits menu bar applications updates.
    /// Emits an array of MenuBarApp instances representing applications with menu bar icons.
    var menuBarAppsPublisher: AnyPublisher<[MenuBarApp], Never> { get }

    /// Publisher that emits screen capture permission status updates.
    /// Emits `true` when screen capture permissions are granted, `false` when denied.
    var screenCapturePermissionGrantedPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits Apple Button (Apple menu icon) frame updates.
    /// Emits `CGRect.zero` when the Apple Button is not detected.
    var appleButtonFramePublisher: AnyPublisher<CGRect, Never> { get }

    // MARK: - Permission Management

    /// Requests screen capture permissions from the user if not already asked.
    func requestScreenCapturePermissions() async
}
