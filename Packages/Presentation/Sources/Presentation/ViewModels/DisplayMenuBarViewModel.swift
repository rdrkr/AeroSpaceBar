// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain

/// Menu bar state local to one spaces panel; workspace data remains shared across panels.
@MainActor
final class DisplayMenuBarViewModel: ObservableObject {
    /// The captured menu bar background for this display.
    @Published private(set) var wallpaper: NSImage?

    /// The current menu bar height on this display.
    @Published private(set) var menuBarHeight = ConfigurationDefaults.menuBarHeight

    /// Whether this display's menu bar is currently visible.
    @Published private(set) var isMenuBarVisible = false

    /// The Apple Button frame on this display, in panel-local coordinates.
    @Published private(set) var appleButtonFrame: CGRect = .zero

    /// Whether groups are drawn on this display.
    @Published var showsGroups = false

    /// Whether the Apple Button background is allowed on this display.
    @Published var showsAppleButton = false

    private var cancellables = Set<AnyCancellable>()

    /// Subscribes to the display-scoped repository through system menu bar use cases.
    init(
        getWallpaperUseCase: GetWallpaperUseCase,
        getMenuBarHeightUseCase: GetMenuBarHeightUseCase,
        getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase,
        getAppleButtonFrameUseCase: GetAppleButtonFrameUseCase
    ) {
        getWallpaperUseCase.execute()
            .sink { [weak self] in self?.wallpaper = $0 }
            .store(in: &cancellables)
        getMenuBarHeightUseCase.execute()
            .sink { [weak self] in self?.menuBarHeight = $0 }
            .store(in: &cancellables)
        getMenuBarVisibilityUseCase.execute()
            .sink { [weak self] in self?.isMenuBarVisible = $0 }
            .store(in: &cancellables)
        getAppleButtonFrameUseCase.execute()
            .sink { [weak self] in self?.appleButtonFrame = $0 }
            .store(in: &cancellables)
    }
}
