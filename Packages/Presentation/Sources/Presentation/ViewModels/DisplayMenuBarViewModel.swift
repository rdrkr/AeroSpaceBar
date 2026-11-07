// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain

/// Menu bar state local to one display's panels; workspace and group data remain shared across panels.
@MainActor
final class DisplayMenuBarViewModel: ObservableObject {
    /// The widths needed to project status items from the primary menu bar onto another display.
    struct StatusItemsGeometry: Equatable {
        /// The width of the primary display, whose menu bar status item frames are expressed in.
        let primaryWidth: CGFloat

        /// The width of this display.
        let displayWidth: CGFloat

        /// The leftmost display-local position where status items can appear.
        let minX: CGFloat
    }

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

    /// The geometry used to place status items on this display, or nil on the primary display.
    @Published var statusItemsGeometry: StatusItemsGeometry?

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

    /// Converts status items from primary menu bar coordinates to this display's panel coordinates.
    /// - Parameter apps: The status items in primary menu bar coordinates.
    /// - Returns: The status items positioned on this display, clipped to its visible status item area.
    func localMenuBarApps(from apps: [MenuBarApp]) -> [MenuBarApp] {
        guard let statusItemsGeometry else { return apps }

        let sourceHeight = apps.first.map { Double($0.frame.height) } ?? menuBarHeight
        let source = CGRect(x: 0, y: 0, width: statusItemsGeometry.primaryWidth, height: sourceHeight)
        let target = CGRect(x: 0, y: 0, width: statusItemsGeometry.displayWidth, height: menuBarHeight)
        return apps.map { app in
            app.projected(from: source, to: target).clipped(toMinX: statusItemsGeometry.minX)
        }
    }
}
