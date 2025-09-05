// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import ServiceManagement
import SwiftUI

/// A coordinator view model that manages the overall settings interface.
///
/// This class coordinates between different settings ViewModels and handles
/// overall settings operations like loading, saving, and resetting all settings.
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Display Properties

    /// The background opacity level of the space elements (0.1 to 1.0).
    @Published var spaceBackgroundOpacity: Double {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceBackgroundOpacityUseCase.execute(spaceBackgroundOpacity: spaceBackgroundOpacity)
            }
        }
    }

    /// The background blur radius for space elements in points.
    @Published var spaceBackgroundBlurRadius: CGFloat {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceBackgroundBlurRadiusUseCase.execute(spaceBackgroundBlurRadius: spaceBackgroundBlurRadius)
            }
        }
    }

    /// The background tint color for space elements.
    @Published var spaceBackgroundTintColor: Color {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceBackgroundTintColorUseCase.execute(spaceBackgroundTintColor: spaceBackgroundTintColor)
            }
        }
    }

    /// The foreground color for space elements.
    @Published var spaceForegroundColor: Color {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceForegroundColorUseCase.execute(spaceForegroundColor: spaceForegroundColor)
            }
        }
    }

    /// The border tint color for space elements.
    @Published var spaceBorderTintColor: Color {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceBorderTintColorUseCase.execute(spaceBorderTintColor: spaceBorderTintColor)
            }
        }
    }

    /// The border opacity level of the space elements (0.0 to 1.0).
    @Published var spaceBorderOpacity: Double {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceBorderOpacityUseCase.execute(spaceBorderOpacity: spaceBorderOpacity)
            }
        }
    }

    /// The border width of the space elements in points.
    @Published var spaceBorderWidth: CGFloat {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceBorderWidthUseCase.execute(spaceBorderWidth: spaceBorderWidth)
            }
        }
    }

    /// Whether to immediately focus a window when clicking on it.
    @Published var focusWindowOnClick: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setFocusWindowOnClickUseCase.execute(enabled: focusWindowOnClick)
            }
        }
    }

    /// Whether to show empty spaces in the interface.
    @Published var showEmptySpaces: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowEmptySpacesUseCase.execute(value: showEmptySpaces)
            }
        }
    }

    /// Whether to show window titles in the interface.
    @Published var showWindowTitles: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowWindowTitlesUseCase.execute(value: showWindowTitles)
            }
        }
    }

    /// The corner radius for spaces in points.
    @Published var spaceCornerRadius: CGFloat {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpaceCornerRadiusUseCase.execute(spaceCornerRadius)
            }
        }
    }

    // MARK: - AeroSpace Properties

    /// The absolute path to the AeroSpace CLI binary.
    @Published var aeroSpacePath: String {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setAeroSpacePathUseCase.execute(value: aeroSpacePath)
            }
        }
    }

    /// The current log level for application logging.
    @Published var logLevel: Logger.Level {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setLogLevelUseCase.execute(value: logLevel)
            }
        }
    }

    /// Whether to enable performance metrics collection and logging.
    @Published var enablePerformanceMetrics: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setEnablePerformanceMetricsUseCase.execute(value: enablePerformanceMetrics)
            }
        }
    }

    /// Whether to enable optimized performance behavior.
    @Published var isOptimizedPerformanceEnabled: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setOptimizedPerformanceEnabledUseCase.execute(value: isOptimizedPerformanceEnabled)
            }
        }
    }

    /// The current AeroSpace version (if available).
    @Published var aeroSpaceVersion: String?

    /// Whether to automatically launch the application at login.
    private var _launchAtLogin: Bool = false
    var launchAtLogin: Bool {
        get {
            let newStatus = SMAppService.mainApp.status == .enabled

            if newStatus != _launchAtLogin {
                _launchAtLogin = newStatus

                Task {
                    objectWillChange.send()
                }
            }

            return _launchAtLogin
        }
        set(newValue) {
            if newValue == launchAtLogin {
                return
            }

            objectWillChange.send()

            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }

                _launchAtLogin = newValue
            } catch {
                Logger.error("Failed to update launch at login setting", error: error, category: Logger.config)
            }
        }
    }

    // MARK: - Display Use Cases

    private let getSpaceBackgroundOpacityUseCase: GetSpaceBackgroundOpacityUseCase
    private let setSpaceBackgroundOpacityUseCase: SetSpaceBackgroundOpacityUseCase
    private let getSpaceBackgroundBlurRadiusUseCase: GetSpaceBackgroundBlurRadiusUseCase
    private let setSpaceBackgroundBlurRadiusUseCase: SetSpaceBackgroundBlurRadiusUseCase
    private let getSpaceBackgroundTintColorUseCase: GetSpaceBackgroundTintColorUseCase
    private let setSpaceBackgroundTintColorUseCase: SetSpaceBackgroundTintColorUseCase
    private let getSpaceForegroundColorUseCase: GetSpaceForegroundColorUseCase
    private let setSpaceForegroundColorUseCase: SetSpaceForegroundColorUseCase
    private let getSpaceBorderTintColorUseCase: GetSpaceBorderTintColorUseCase
    private let setSpaceBorderTintColorUseCase: SetSpaceBorderTintColorUseCase
    private let getSpaceBorderOpacityUseCase: GetSpaceBorderOpacityUseCase
    private let setSpaceBorderOpacityUseCase: SetSpaceBorderOpacityUseCase
    private let getSpaceBorderWidthUseCase: GetSpaceBorderWidthUseCase
    private let setSpaceBorderWidthUseCase: SetSpaceBorderWidthUseCase
    private let getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase
    private let setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase
    private let getShowEmptySpacesUseCase: GetShowEmptySpacesUseCase
    private let setShowEmptySpacesUseCase: SetShowEmptySpacesUseCase
    private let getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase
    private let setShowWindowTitlesUseCase: SetShowWindowTitlesUseCase
    private let getSpaceCornerRadiusUseCase: GetSpaceCornerRadiusUseCase
    private let setSpaceCornerRadiusUseCase: SetSpaceCornerRadiusUseCase

    // MARK: - AeroSpace Use Cases

    private let getAeroSpacePathUseCase: GetAeroSpacePathUseCase
    private let setAeroSpacePathUseCase: SetAeroSpacePathUseCase
    private let getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase
    private let openAeroSpaceConfigUseCase: OpenAeroSpaceConfigUseCase
    private let resetConfigurationUseCase: ResetConfigurationUseCase
    private let getLogLevelUseCase: GetLogLevelUseCase
    private let setLogLevelUseCase: SetLogLevelUseCase
    private let getEnablePerformanceMetricsUseCase: GetEnablePerformanceMetricsUseCase
    private let setEnablePerformanceMetricsUseCase: SetEnablePerformanceMetricsUseCase
    private let getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase
    private let setOptimizedPerformanceEnabledUseCase: SetOptimizedPerformanceEnabledUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the settings view model with dependencies.
    init(
        getSpaceBackgroundOpacityUseCase: GetSpaceBackgroundOpacityUseCase,
        setSpaceBackgroundOpacityUseCase: SetSpaceBackgroundOpacityUseCase,
        getSpaceBackgroundBlurRadiusUseCase: GetSpaceBackgroundBlurRadiusUseCase,
        setSpaceBackgroundBlurRadiusUseCase: SetSpaceBackgroundBlurRadiusUseCase,
        getSpaceBackgroundTintColorUseCase: GetSpaceBackgroundTintColorUseCase,
        setSpaceBackgroundTintColorUseCase: SetSpaceBackgroundTintColorUseCase,
        getSpaceForegroundColorUseCase: GetSpaceForegroundColorUseCase,
        setSpaceForegroundColorUseCase: SetSpaceForegroundColorUseCase,
        getSpaceBorderTintColorUseCase: GetSpaceBorderTintColorUseCase,
        setSpaceBorderTintColorUseCase: SetSpaceBorderTintColorUseCase,
        getSpaceBorderOpacityUseCase: GetSpaceBorderOpacityUseCase,
        setSpaceBorderOpacityUseCase: SetSpaceBorderOpacityUseCase,
        getSpaceBorderWidthUseCase: GetSpaceBorderWidthUseCase,
        setSpaceBorderWidthUseCase: SetSpaceBorderWidthUseCase,
        getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase,
        setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase,
        getShowEmptySpacesUseCase: GetShowEmptySpacesUseCase,
        setShowEmptySpacesUseCase: SetShowEmptySpacesUseCase,
        getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase,
        setShowWindowTitlesUseCase: SetShowWindowTitlesUseCase,
        getSpaceCornerRadiusUseCase: GetSpaceCornerRadiusUseCase,
        setSpaceCornerRadiusUseCase: SetSpaceCornerRadiusUseCase,
        getAeroSpacePathUseCase: GetAeroSpacePathUseCase,
        setAeroSpacePathUseCase: SetAeroSpacePathUseCase,
        getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase,
        openAeroSpaceConfigUseCase: OpenAeroSpaceConfigUseCase,
        resetConfigurationUseCase: ResetConfigurationUseCase,
        getLogLevelUseCase: GetLogLevelUseCase,
        setLogLevelUseCase: SetLogLevelUseCase,
        getEnablePerformanceMetricsUseCase: GetEnablePerformanceMetricsUseCase,
        setEnablePerformanceMetricsUseCase: SetEnablePerformanceMetricsUseCase,
        getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase,
        setOptimizedPerformanceEnabledUseCase: SetOptimizedPerformanceEnabledUseCase
    ) {
        // Initialize Display Use Cases
        self.getSpaceBackgroundOpacityUseCase = getSpaceBackgroundOpacityUseCase
        self.setSpaceBackgroundOpacityUseCase = setSpaceBackgroundOpacityUseCase
        self.getSpaceBackgroundBlurRadiusUseCase = getSpaceBackgroundBlurRadiusUseCase
        self.setSpaceBackgroundBlurRadiusUseCase = setSpaceBackgroundBlurRadiusUseCase
        self.getSpaceBackgroundTintColorUseCase = getSpaceBackgroundTintColorUseCase
        self.setSpaceBackgroundTintColorUseCase = setSpaceBackgroundTintColorUseCase
        self.getSpaceForegroundColorUseCase = getSpaceForegroundColorUseCase
        self.setSpaceForegroundColorUseCase = setSpaceForegroundColorUseCase
        self.getSpaceBorderTintColorUseCase = getSpaceBorderTintColorUseCase
        self.setSpaceBorderTintColorUseCase = setSpaceBorderTintColorUseCase
        self.getSpaceBorderOpacityUseCase = getSpaceBorderOpacityUseCase
        self.setSpaceBorderOpacityUseCase = setSpaceBorderOpacityUseCase
        self.getSpaceBorderWidthUseCase = getSpaceBorderWidthUseCase
        self.setSpaceBorderWidthUseCase = setSpaceBorderWidthUseCase
        self.getFocusWindowOnClickUseCase = getFocusWindowOnClickUseCase
        self.setFocusWindowOnClickUseCase = setFocusWindowOnClickUseCase
        self.getShowEmptySpacesUseCase = getShowEmptySpacesUseCase
        self.setShowEmptySpacesUseCase = setShowEmptySpacesUseCase
        self.getShowWindowTitlesUseCase = getShowWindowTitlesUseCase
        self.setShowWindowTitlesUseCase = setShowWindowTitlesUseCase
        self.getSpaceCornerRadiusUseCase = getSpaceCornerRadiusUseCase
        self.setSpaceCornerRadiusUseCase = setSpaceCornerRadiusUseCase

        // Initialize AeroSpace Use Cases
        self.getAeroSpacePathUseCase = getAeroSpacePathUseCase
        self.setAeroSpacePathUseCase = setAeroSpacePathUseCase
        self.getAeroSpaceVersionUseCase = getAeroSpaceVersionUseCase
        self.openAeroSpaceConfigUseCase = openAeroSpaceConfigUseCase
        self.resetConfigurationUseCase = resetConfigurationUseCase
        self.getLogLevelUseCase = getLogLevelUseCase
        self.setLogLevelUseCase = setLogLevelUseCase
        self.getEnablePerformanceMetricsUseCase = getEnablePerformanceMetricsUseCase
        self.setEnablePerformanceMetricsUseCase = setEnablePerformanceMetricsUseCase
        self.getOptimizedPerformanceEnabledUseCase = getOptimizedPerformanceEnabledUseCase
        self.setOptimizedPerformanceEnabledUseCase = setOptimizedPerformanceEnabledUseCase

        // Load initial values from use cases
        spaceBackgroundOpacity = getSpaceBackgroundOpacityUseCase.execute().blockingFirst()
        spaceBackgroundBlurRadius = getSpaceBackgroundBlurRadiusUseCase.execute().blockingFirst()
        spaceBackgroundTintColor = getSpaceBackgroundTintColorUseCase.execute().blockingFirst()
        spaceForegroundColor = getSpaceForegroundColorUseCase.execute().blockingFirst()
        spaceBorderTintColor = getSpaceBorderTintColorUseCase.execute().blockingFirst()
        spaceBorderOpacity = getSpaceBorderOpacityUseCase.execute().blockingFirst()
        spaceBorderWidth = getSpaceBorderWidthUseCase.execute().blockingFirst()
        focusWindowOnClick = getFocusWindowOnClickUseCase.execute().blockingFirst()
        showEmptySpaces = getShowEmptySpacesUseCase.execute().blockingFirst()
        showWindowTitles = getShowWindowTitlesUseCase.execute().blockingFirst()
        spaceCornerRadius = getSpaceCornerRadiusUseCase.execute().blockingFirst()
        aeroSpacePath = getAeroSpacePathUseCase.execute().blockingFirst()
        aeroSpaceVersion = getAeroSpaceVersionUseCase.execute().blockingFirst()
        logLevel = getLogLevelUseCase.execute().blockingFirst()
        enablePerformanceMetrics = getEnablePerformanceMetricsUseCase.execute().blockingFirst()
        isOptimizedPerformanceEnabled = getOptimizedPerformanceEnabledUseCase.execute().blockingFirst()

        // Setup reactive subscriptions
        setupReactiveSubscriptions()
    }

    // MARK: - Computed Properties

    /// Custom path validation error message.
    var customPathValidationError: String? {
        let customPath = aeroSpacePath

        // If path is empty, that's fine (auto-detection will be used)
        if customPath.isEmpty {
            return nil
        }

        // Check if file exists and is executable
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: customPath) {
            return "File does not exist at specified path"
        }

        if !fileManager.isExecutableFile(atPath: customPath) {
            return "File is not executable"
        }

        return nil
    }

    // MARK: - Public Methods

    /// Resets all settings to their default values.
    func resetAllSettings() async {
        await resetConfigurationUseCase.execute()
    }

    /// Opens the AeroSpace configuration file.
    func openAeroSpaceConfig() async {
        await openAeroSpaceConfigUseCase.execute()
    }

    // MARK: - Private Methods

    /// Setup reactive subscriptions to UseCase publishers.
    private func setupReactiveSubscriptions() {
        // Monitor configuration changes
        getSpaceBackgroundOpacityUseCase.execute()
            .assign(to: \.spaceBackgroundOpacity, on: self)
            .store(in: &cancellables)

        getSpaceBackgroundBlurRadiusUseCase.execute()
            .assign(to: \.spaceBackgroundBlurRadius, on: self)
            .store(in: &cancellables)

        getSpaceBackgroundTintColorUseCase.execute()
            .assign(to: \.spaceBackgroundTintColor, on: self)
            .store(in: &cancellables)

        getSpaceForegroundColorUseCase.execute()
            .assign(to: \.spaceForegroundColor, on: self)
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

        getFocusWindowOnClickUseCase.execute()
            .assign(to: \.focusWindowOnClick, on: self)
            .store(in: &cancellables)

        getShowEmptySpacesUseCase.execute()
            .assign(to: \.showEmptySpaces, on: self)
            .store(in: &cancellables)

        getShowWindowTitlesUseCase.execute()
            .assign(to: \.showWindowTitles, on: self)
            .store(in: &cancellables)

        getSpaceCornerRadiusUseCase.execute()
            .assign(to: \.spaceCornerRadius, on: self)
            .store(in: &cancellables)

        getAeroSpacePathUseCase.execute()
            .assign(to: \.aeroSpacePath, on: self)
            .store(in: &cancellables)

        getAeroSpaceVersionUseCase.execute()
            .assign(to: \.aeroSpaceVersion, on: self)
            .store(in: &cancellables)

        getLogLevelUseCase.execute()
            .assign(to: \.logLevel, on: self)
            .store(in: &cancellables)

        getEnablePerformanceMetricsUseCase.execute()
            .assign(to: \.enablePerformanceMetrics, on: self)
            .store(in: &cancellables)

        getOptimizedPerformanceEnabledUseCase.execute()
            .assign(to: \.isOptimizedPerformanceEnabled, on: self)
            .store(in: &cancellables)
    }
}
