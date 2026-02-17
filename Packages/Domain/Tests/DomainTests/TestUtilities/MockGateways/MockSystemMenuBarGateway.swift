// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Domain
import Foundation

/// Mock implementation of SystemMenuBarGateway for testing.
///
/// This mock allows tests to verify system menu bar interactions and control
/// the values emitted by publishers.
@MainActor
public final class MockSystemMenuBarGateway: SystemMenuBarGateway {
    // MARK: - Call Tracking

    public private(set) var requestScreenCapturePermissionsCalls: Int = 0

    // MARK: - Configurable Values

    public var wallpaperToEmit: NSImage?
    public var menuBarHeightToEmit: Double = 25.0
    public var menuBarVisibilityToEmit: Bool = true
    public var menuBarAppsToEmit: [MenuBarApp] = []
    public var screenCapturePermissionGrantedToEmit: Bool = false

    // MARK: - Test Access Properties

    public var wallpaper: NSImage? {
        get { wallpaperToEmit }
        set {
            wallpaperToEmit = newValue
            wallpaperSubject.send(newValue)
        }
    }

    public var menuBarHeight: Double {
        get { menuBarHeightToEmit }
        set {
            menuBarHeightToEmit = newValue
            menuBarHeightSubject.send(newValue)
        }
    }

    public var menuBarVisibility: Bool {
        get { menuBarVisibilityToEmit }
        set {
            menuBarVisibilityToEmit = newValue
            menuBarVisibilitySubject.send(newValue)
        }
    }

    public var menuBarApps: [MenuBarApp] {
        get { menuBarAppsToEmit }
        set {
            menuBarAppsToEmit = newValue
            menuBarAppsSubject.send(newValue)
        }
    }

    public var screenCapturePermissionGranted: Bool {
        get { screenCapturePermissionGrantedToEmit }
        set {
            screenCapturePermissionGrantedToEmit = newValue
            screenCapturePermissionGrantedSubject.send(newValue)
        }
    }

    // MARK: - Subjects

    private let wallpaperSubject: CurrentValueSubject<NSImage?, Never>
    private let menuBarHeightSubject: CurrentValueSubject<Double, Never>
    private let menuBarVisibilitySubject: CurrentValueSubject<Bool, Never>
    private let menuBarAppsSubject: CurrentValueSubject<[MenuBarApp], Never>
    private let screenCapturePermissionGrantedSubject: CurrentValueSubject<Bool, Never>

    // MARK: - Initialization

    public init() {
        wallpaperSubject = CurrentValueSubject(wallpaperToEmit)
        menuBarHeightSubject = CurrentValueSubject(menuBarHeightToEmit)
        menuBarVisibilitySubject = CurrentValueSubject(menuBarVisibilityToEmit)
        menuBarAppsSubject = CurrentValueSubject(menuBarAppsToEmit)
        screenCapturePermissionGrantedSubject = CurrentValueSubject(screenCapturePermissionGrantedToEmit)
    }

    // MARK: - Publishers

    public var wallpaperPublisher: AnyPublisher<NSImage?, Never> {
        wallpaperSubject.eraseToAnyPublisher()
    }

    public var menuBarHeightPublisher: AnyPublisher<Double, Never> {
        menuBarHeightSubject.eraseToAnyPublisher()
    }

    public var menuBarVisibilityPublisher: AnyPublisher<Bool, Never> {
        menuBarVisibilitySubject.eraseToAnyPublisher()
    }

    public var menuBarAppsPublisher: AnyPublisher<[MenuBarApp], Never> {
        menuBarAppsSubject.eraseToAnyPublisher()
    }

    public var screenCapturePermissionGrantedPublisher: AnyPublisher<Bool, Never> {
        screenCapturePermissionGrantedSubject.eraseToAnyPublisher()
    }

    // MARK: - Methods

    public func requestScreenCapturePermissions() {
        requestScreenCapturePermissionsCalls += 1
        screenCapturePermissionGranted = true
    }

    // MARK: - Test Helpers

    public func reset() {
        requestScreenCapturePermissionsCalls = 0
    }

    public func emitWallpaper(_ image: NSImage?) {
        wallpaperSubject.send(image)
    }

    public func emitMenuBarHeight(_ height: Double) {
        menuBarHeightSubject.send(height)
    }

    public func emitMenuBarVisibility(_ visible: Bool) {
        menuBarVisibilitySubject.send(visible)
    }

    public func emitMenuBarApps(_ apps: [MenuBarApp]) {
        menuBarAppsSubject.send(apps)
    }

    public func emitScreenCapturePermissionGranted(_ granted: Bool) {
        screenCapturePermissionGrantedSubject.send(granted)
    }
}
