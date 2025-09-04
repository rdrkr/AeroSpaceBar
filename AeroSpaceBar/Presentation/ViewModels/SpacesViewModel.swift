// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import SwiftUI

/// ViewModel for managing spaces data and interactions.
///
/// This ViewModel manages the state of spaces data, including fetching,
/// updating, and providing user interactions for spaces and windows.
/// It runs on the main actor and uses Combine for reactive updates.
@MainActor
final class SpacesViewModel: ObservableObject {
    /// The widget components state.
    struct WidgetState: Equatable {
        /// The current desktop wallpaper image.
        let wallpaper: NSImage?

        /// The list of available spaces with their associated windows.
        let spaces: [Space]
    }

    /// Whether AeroSpace is currently running on the system.
    @Published var isAeroSpaceRunning: Bool

    /// The current state of the widget.
    @Published var widgetState: WidgetState

    /// UI configuration properties.
    @Published var menuBarHeight: CGFloat
    @Published var menuBarVerticalPadding: CGFloat
    @Published var menuBarHorizontalPadding: CGFloat
    @Published var widgetSpacing: CGFloat
    @Published var animationDuration: Double
    @Published var windowIconSize: CGFloat
    @Published var spaceCornerRadius: CGFloat
    @Published var showWindowTitles: Bool
    @Published var focusWindowOnClick: Bool
    @Published var spaceBackgroundOpacity: Double
    @Published var spaceBackgroundBlurRadius: CGFloat
    @Published var spaceBackgroundTintColor: Color
    @Published var spaceForegroundColor: Color
    @Published var spaceBorderTintColor: Color
    @Published var spaceBorderOpacity: Double
    @Published var spaceBorderWidth: CGFloat

    // MARK: - Spaces Use Cases

    /// The use cases for spaces operations.
    private let getSpacesUseCase: GetSpacesUseCase
    private let setFocusSpaceUseCase: SetFocusSpaceUseCase
    private let setFocusWindowUseCase: SetFocusWindowUseCase
    private let getAeroSpaceStatusUseCase: GetAeroSpaceStatusUseCase

    /// Use case for getting desktop wallpaper image.
    private let getWallpaperUseCase: GetWallpaperUseCase

    /// Use cases for UI configuration properties.
    private let getMenuBarHeightUseCase: GetMenuBarHeightUseCase
    private let getMenuBarVerticalPaddingUseCase: GetMenuBarVerticalPaddingUseCase
    private let getMenuBarHorizontalPaddingUseCase: GetMenuBarHorizontalPaddingUseCase
    private let getWidgetSpacingUseCase: GetWidgetSpacingUseCase
    private let getAnimationDurationUseCase: GetAnimationDurationUseCase
    private let getWindowIconSizeUseCase: GetWindowIconSizeUseCase
    private let getSpaceCornerRadiusUseCase: GetSpaceCornerRadiusUseCase
    private let getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase
    private let getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase
    private let getSpaceBackgroundOpacityUseCase: GetSpaceBackgroundOpacityUseCase
    private let getSpaceBackgroundBlurRadiusUseCase: GetSpaceBackgroundBlurRadiusUseCase
    private let getSpaceBackgroundTintColorUseCase: GetSpaceBackgroundTintColorUseCase
    private let getSpaceForegroundColorUseCase: GetSpaceForegroundColorUseCase
    private let getSpaceBorderTintColorUseCase: GetSpaceBorderTintColorUseCase
    private let getSpaceBorderOpacityUseCase: GetSpaceBorderOpacityUseCase
    private let getSpaceBorderWidthUseCase: GetSpaceBorderWidthUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    /// Initializes the spaces ViewModel with the specified dependencies.
    ///
    /// This initializer sets up all use cases and begins monitoring for data updates.
    /// - Parameters:
    ///   - getSpacesUseCase: Use case for getting spaces data
    ///   - setFocusSpaceUseCase: Use case for focusing spaces
    ///   - setFocusWindowUseCase: Use case for focusing windows
    ///   - getAeroSpaceStatusUseCase: Use case for checking AeroSpace status
    ///   - getShowWindowTitlesUseCase: Use case for getting window titles display setting
    ///   - getWallpaperUseCase: Use case for getting wallpaper image
    ///   - getMenuBarHeightUseCase: Use case for getting menu bar height
    ///   - getMenuBarVerticalPaddingUseCase: Use case for getting vertical padding
    ///   - getMenuBarHorizontalPaddingUseCase: Use case for getting horizontal padding
    ///   - getWidgetSpacingUseCase: Use case for getting widget spacing
    ///   - getAnimationDurationUseCase: Use case for getting animation duration
    ///   - getWindowIconSizeUseCase: Use case for getting window icon size
    ///   - getSpaceCornerRadiusUseCase: Use case for getting space corner radius
    init(
        getSpacesUseCase: GetSpacesUseCase,
        setFocusSpaceUseCase: SetFocusSpaceUseCase,
        setFocusWindowUseCase: SetFocusWindowUseCase,
        getAeroSpaceStatusUseCase: GetAeroSpaceStatusUseCase,
        getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase,
        getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase,
        getWallpaperUseCase: GetWallpaperUseCase,
        getMenuBarHeightUseCase: GetMenuBarHeightUseCase,
        getMenuBarVerticalPaddingUseCase: GetMenuBarVerticalPaddingUseCase,
        getMenuBarHorizontalPaddingUseCase: GetMenuBarHorizontalPaddingUseCase,
        getWidgetSpacingUseCase: GetWidgetSpacingUseCase,
        getAnimationDurationUseCase: GetAnimationDurationUseCase,
        getWindowIconSizeUseCase: GetWindowIconSizeUseCase,
        getSpaceCornerRadiusUseCase: GetSpaceCornerRadiusUseCase,
        getSpaceBackgroundOpacityUseCase: GetSpaceBackgroundOpacityUseCase,
        getSpaceBackgroundBlurRadiusUseCase: GetSpaceBackgroundBlurRadiusUseCase,
        getSpaceBackgroundTintColorUseCase: GetSpaceBackgroundTintColorUseCase,
        getSpaceForegroundColorUseCase: GetSpaceForegroundColorUseCase,
        getSpaceBorderTintColorUseCase: GetSpaceBorderTintColorUseCase,
        getSpaceBorderOpacityUseCase: GetSpaceBorderOpacityUseCase,
        getSpaceBorderWidthUseCase: GetSpaceBorderWidthUseCase
    ) {
        // Initialize spaces use cases
        self.getSpacesUseCase = getSpacesUseCase
        self.setFocusSpaceUseCase = setFocusSpaceUseCase
        self.setFocusWindowUseCase = setFocusWindowUseCase
        self.getAeroSpaceStatusUseCase = getAeroSpaceStatusUseCase

        // Initialize wallpaper use case
        self.getWallpaperUseCase = getWallpaperUseCase
        self.getShowWindowTitlesUseCase = getShowWindowTitlesUseCase
        self.getFocusWindowOnClickUseCase = getFocusWindowOnClickUseCase

        // Initialize UI configuration use cases
        self.getMenuBarHeightUseCase = getMenuBarHeightUseCase
        self.getMenuBarVerticalPaddingUseCase = getMenuBarVerticalPaddingUseCase
        self.getMenuBarHorizontalPaddingUseCase = getMenuBarHorizontalPaddingUseCase
        self.getWidgetSpacingUseCase = getWidgetSpacingUseCase
        self.getAnimationDurationUseCase = getAnimationDurationUseCase
        self.getWindowIconSizeUseCase = getWindowIconSizeUseCase
        self.getSpaceCornerRadiusUseCase = getSpaceCornerRadiusUseCase
        self.getSpaceBackgroundOpacityUseCase = getSpaceBackgroundOpacityUseCase
        self.getSpaceBackgroundBlurRadiusUseCase = getSpaceBackgroundBlurRadiusUseCase
        self.getSpaceBorderTintColorUseCase = getSpaceBorderTintColorUseCase
        self.getSpaceBorderOpacityUseCase = getSpaceBorderOpacityUseCase
        self.getSpaceBorderWidthUseCase = getSpaceBorderWidthUseCase
        self.getSpaceBackgroundTintColorUseCase = getSpaceBackgroundTintColorUseCase
        self.getSpaceForegroundColorUseCase = getSpaceForegroundColorUseCase

        // Load initial values from use cases
        isAeroSpaceRunning = getAeroSpaceStatusUseCase.execute().blockingFirst()
        widgetState = WidgetState(
            wallpaper: getWallpaperUseCase.execute().blockingFirst(),
            spaces: getSpacesUseCase.execute().blockingFirst()
        )

        menuBarHeight = getMenuBarHeightUseCase.execute().blockingFirst()
        menuBarVerticalPadding = getMenuBarVerticalPaddingUseCase.execute().blockingFirst()
        menuBarHorizontalPadding = getMenuBarHorizontalPaddingUseCase.execute().blockingFirst()
        widgetSpacing = getWidgetSpacingUseCase.execute().blockingFirst()
        animationDuration = getAnimationDurationUseCase.execute().blockingFirst()
        windowIconSize = getWindowIconSizeUseCase.execute().blockingFirst()
        spaceCornerRadius = getSpaceCornerRadiusUseCase.execute().blockingFirst()
        showWindowTitles = getShowWindowTitlesUseCase.execute().blockingFirst()
        focusWindowOnClick = getFocusWindowOnClickUseCase.execute().blockingFirst()
        spaceBackgroundOpacity = getSpaceBackgroundOpacityUseCase.execute().blockingFirst()
        spaceBackgroundBlurRadius = getSpaceBackgroundBlurRadiusUseCase.execute().blockingFirst()
        spaceBorderTintColor = getSpaceBorderTintColorUseCase.execute().blockingFirst()
        spaceBorderOpacity = getSpaceBorderOpacityUseCase.execute().blockingFirst()
        spaceBorderWidth = getSpaceBorderWidthUseCase.execute().blockingFirst()
        spaceBackgroundTintColor = getSpaceBackgroundTintColorUseCase.execute().blockingFirst()
        spaceForegroundColor = getSpaceForegroundColorUseCase.execute().blockingFirst()

        setupReactiveSubscriptions()
    }

    // MARK: - Public Methods

    /// Switches to a specific space.
    ///
    /// This method sends a command to focus the specified space and optionally
    /// focus a window within that space.
    /// - Parameters:
    ///   - space: The space to switch to
    ///   - needWindowFocus: Whether to also focus a window in the space
    func switchToSpace(_ space: Space, needWindowFocus: Bool = false) {
        Task {
            await focusSpace(space, needWindowFocus: needWindowFocus)
        }
    }

    /// Switches to a specific window.
    ///
    /// This method sends a command to focus the specified window.
    /// - Parameter window: The window to switch to
    func switchToWindow(_ window: Window) {
        Task {
            await focusWindow(window)
        }
    }

    // MARK: - Private Methods

    /// Sets up reactive bindings for state changes.
    ///
    /// This method establishes Combine subscriptions to monitor changes
    /// in UI configuration and wallpaper, responding accordingly.
    private func setupReactiveSubscriptions() {
        // Monitor AeroSpace running status changes
        getAeroSpaceStatusUseCase.execute()
            .assign(to: \.isAeroSpaceRunning, on: self)
            .store(in: &cancellables)

        // Monitor wallpaper and spaces changes
        getWallpaperUseCase.execute()
            .combineLatest(getSpacesUseCase.execute())
            .sink { [weak self] wallpaper, spaces in
                let sortedSpaces = spaces.sorted {
                    $0.id < $1.id
                }
                self?.widgetState = WidgetState(wallpaper: wallpaper, spaces: sortedSpaces)
            }
            .store(in: &cancellables)

        // Monitor UI configuration changes
        getMenuBarHeightUseCase.execute()
            .assign(to: \.menuBarHeight, on: self)
            .store(in: &cancellables)

        getMenuBarVerticalPaddingUseCase.execute()
            .assign(to: \.menuBarVerticalPadding, on: self)
            .store(in: &cancellables)

        getMenuBarHorizontalPaddingUseCase.execute()
            .assign(to: \.menuBarHorizontalPadding, on: self)
            .store(in: &cancellables)

        getWidgetSpacingUseCase.execute()
            .assign(to: \.widgetSpacing, on: self)
            .store(in: &cancellables)

        getAnimationDurationUseCase.execute()
            .assign(to: \.animationDuration, on: self)
            .store(in: &cancellables)

        getWindowIconSizeUseCase.execute()
            .assign(to: \.windowIconSize, on: self)
            .store(in: &cancellables)

        getSpaceCornerRadiusUseCase.execute()
            .assign(to: \.spaceCornerRadius, on: self)
            .store(in: &cancellables)

        getShowWindowTitlesUseCase.execute()
            .assign(to: \.showWindowTitles, on: self)
            .store(in: &cancellables)
        getFocusWindowOnClickUseCase.execute()
            .assign(to: \.focusWindowOnClick, on: self)
            .store(in: &cancellables)

        getSpaceBackgroundOpacityUseCase.execute()
            .assign(to: \.spaceBackgroundOpacity, on: self)
            .store(in: &cancellables)

        getSpaceBackgroundBlurRadiusUseCase.execute()
            .assign(to: \.spaceBackgroundBlurRadius, on: self)
            .store(in: &cancellables)

        getSpaceBorderTintColorUseCase.execute()
            .assign(to: \.spaceBorderTintColor, on: self)
            .store(in: &cancellables)

        getSpaceBorderOpacityUseCase.execute()
            .assign(to: \.spaceBorderOpacity, on: self)
            .store(in: &cancellables)

        getSpaceBorderWidthUseCase.execute()
            .assign(to: \.spaceBorderWidth, on: self)
            .store(in: &cancellables)

        getSpaceBackgroundTintColorUseCase.execute()
            .assign(to: \.spaceBackgroundTintColor, on: self)
            .store(in: &cancellables)

        getSpaceForegroundColorUseCase.execute()
            .assign(to: \.spaceForegroundColor, on: self)
            .store(in: &cancellables)
    }

    /// Focuses a specific space.
    ///
    /// This method sends a command to focus the specified space and
    /// refreshes the spaces data afterward.
    /// - Parameters:
    ///   - space: The space to focus
    ///   - needWindowFocus: Whether to also focus a window in the space
    private func focusSpace(_ space: Space, needWindowFocus: Bool) async {
        do {
            try await setFocusSpaceUseCase.execute(spaceId: space.id, needWindowFocus: needWindowFocus)
        } catch {
            Logger.error("Error focusing space", error: error, category: Logger.spaces)
        }
    }

    /// Focuses a specific window.
    ///
    /// This method sends a command to focus the specified window and
    /// refreshes the spaces data afterward.
    /// - Parameter window: The window to focus
    private func focusWindow(_ window: Window) async {
        do {
            try await setFocusWindowUseCase.execute(windowId: String(window.id))
        } catch {
            Logger.error("Error focusing window", error: error, category: Logger.spaces)
        }
    }
}
