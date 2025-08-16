// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import ServiceManagement

/// A coordinator view model that manages the overall settings interface.
///
/// This class coordinates between different settings ViewModels and handles
/// overall settings operations like loading, saving, and resetting all settings.
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Display Properties

    /// The transparency level of the menu bar panel (0.1 to 1.0).
    @Published var transparency: Double {
        didSet {
            Task {
                await setTransparencyUseCase.execute(transparency: transparency)
            }
        }
    }

    /// Whether to immediately focus a window when clicking on it.
    @Published var focusWindowOnClick: Bool {
        didSet {
            Task {
                await setFocusWindowOnClickUseCase.execute(enabled: focusWindowOnClick)
            }
        }
    }

    // MARK: - AeroSpace Properties

    /// The absolute path to the AeroSpace CLI binary.
    @Published var aeroSpacePath: String {
        didSet {
            Task {
                await setAeroSpacePathUseCase.execute(value: aeroSpacePath)
            }
        }
    }

    /// The current log level for application logging.
    @Published var logLevel: Logger.Level {
        didSet {
            Task {
                await setLogLevelUseCase.execute(value: logLevel)
            }
        }
    }

    /// Whether to enable performance metrics collection and logging.
    @Published var enablePerformanceMetrics: Bool {
        didSet {
            Task {
                await setEnablePerformanceMetricsUseCase.execute(value: enablePerformanceMetrics)
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
            if newValue == launchAtLogin { return }

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

    private let getTransparencyUseCase: GetTransparencyUseCase
    private let setTransparencyUseCase: SetTransparencyUseCase
    private let getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase
    private let setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase

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

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the settings view model with dependencies.
    init(
        getTransparencyUseCase: GetTransparencyUseCase,
        setTransparencyUseCase: SetTransparencyUseCase,
        getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase,
        setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase,
        getAeroSpacePathUseCase: GetAeroSpacePathUseCase,
        setAeroSpacePathUseCase: SetAeroSpacePathUseCase,
        getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase,
        openAeroSpaceConfigUseCase: OpenAeroSpaceConfigUseCase,
        resetConfigurationUseCase: ResetConfigurationUseCase,
        getLogLevelUseCase: GetLogLevelUseCase,
        setLogLevelUseCase: SetLogLevelUseCase,
        getEnablePerformanceMetricsUseCase: GetEnablePerformanceMetricsUseCase,
        setEnablePerformanceMetricsUseCase: SetEnablePerformanceMetricsUseCase
    ) {
        // Initialize Display Use Cases
        self.getTransparencyUseCase = getTransparencyUseCase
        self.setTransparencyUseCase = setTransparencyUseCase
        self.getFocusWindowOnClickUseCase = getFocusWindowOnClickUseCase
        self.setFocusWindowOnClickUseCase = setFocusWindowOnClickUseCase

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

        // Load initial values from use cases
        transparency = getTransparencyUseCase.execute().blockingFirst()
        focusWindowOnClick = getFocusWindowOnClickUseCase.execute().blockingFirst()
        aeroSpacePath = getAeroSpacePathUseCase.execute().blockingFirst()
        aeroSpaceVersion = getAeroSpaceVersionUseCase.execute().blockingFirst()
        logLevel = getLogLevelUseCase.execute().blockingFirst()
        enablePerformanceMetrics = getEnablePerformanceMetricsUseCase.execute().blockingFirst()

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
        getTransparencyUseCase.execute()
            .assign(to: \.transparency, on: self)
            .store(in: &cancellables)

        getFocusWindowOnClickUseCase.execute()
            .assign(to: \.focusWindowOnClick, on: self)
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
    }
}
