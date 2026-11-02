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

    private var cancellables = Set<AnyCancellable>()

    /// Subscribes to the display-scoped repository through system menu bar use cases.
    init(
        getWallpaperUseCase: GetWallpaperUseCase,
        getMenuBarHeightUseCase: GetMenuBarHeightUseCase,
        getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase
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
    }
}
