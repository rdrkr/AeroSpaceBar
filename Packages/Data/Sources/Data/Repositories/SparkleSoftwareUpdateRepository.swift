// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation
import Sparkle

/// Repository for managing software updates using Sparkle framework.
///
/// This repository provides centralized access to software update functionality,
/// including automatic update checks, downloads, and manual update triggers.
/// It wraps the Sparkle framework and exposes it through reactive patterns with Combine publishers.
/// This is the data layer implementation of the SoftwareUpdateGateway.
@MainActor
public final class SparkleSoftwareUpdateRepository: SoftwareUpdateGateway {
    // MARK: - Properties

    /// Sparkle updater controller.
    private let updaterController: SparkleUpdaterControllerProtocol

    /// Cancellables for publisher subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Subject for automatic check for updates enabled state.
    private let automaticCheckForUpdatesEnabledSubject: CurrentValueSubject<Bool, Never>

    /// Subject for automatic download updates enabled state.
    private let automaticDownloadUpdatesEnabledSubject: CurrentValueSubject<Bool, Never>

    /// Subject for last update check date.
    private let lastUpdateCheckDateSubject: CurrentValueSubject<Date?, Never>

    // MARK: - Publishers

    /// Publisher for automatic check for updates enabled state.
    public var automaticCheckForUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticCheckForUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    /// Publisher for automatic download updates enabled state.
    public var automaticDownloadUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticDownloadUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    /// Publisher for last update check date.
    public var lastUpdateCheckDatePublisher: AnyPublisher<Date?, Never> {
        lastUpdateCheckDateSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    public init(updaterController: SparkleUpdaterControllerProtocol? = nil) {
        // Initialize or use provided updater controller
        self.updaterController = updaterController ?? SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // Initialize subjects with current Sparkle values
        automaticCheckForUpdatesEnabledSubject = CurrentValueSubject<Bool, Never>(
            self.updaterController.sparkleUpdater.automaticallyChecksForUpdates
        )

        automaticDownloadUpdatesEnabledSubject = CurrentValueSubject<Bool, Never>(
            self.updaterController.sparkleUpdater.automaticallyDownloadsUpdates
        )

        lastUpdateCheckDateSubject = CurrentValueSubject<Date?, Never>(
            self.updaterController.sparkleUpdater.lastUpdateCheckDate
        )

        setupObservers()
    }

    // MARK: - Private Methods

    /// Sets up observers for Sparkle updater changes.
    private func setupObservers() {
        // Observe changes to automatic check for updates
        updaterController.sparkleUpdater
            .publisherForAutomaticallyChecksForUpdates()
            .sink { [weak self] value in
                guard self?.automaticCheckForUpdatesEnabledSubject.value != value else { return }

                self?.automaticCheckForUpdatesEnabledSubject.send(value)
            }
            .store(in: &cancellables)

        // Observe changes to automatic download updates
        updaterController.sparkleUpdater
            .publisherForAutomaticallyDownloadsUpdates()
            .sink { [weak self] value in
                guard self?.automaticDownloadUpdatesEnabledSubject.value != value else { return }

                self?.automaticDownloadUpdatesEnabledSubject.send(value)
            }
            .store(in: &cancellables)

        // Observe changes to last update check date
        updaterController.sparkleUpdater
            .publisherForLastUpdateCheckDate()
            .sink { [weak self] value in
                guard self?.lastUpdateCheckDateSubject.value != value else { return }

                self?.lastUpdateCheckDateSubject.send(value)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// Sets whether automatic check for updates is enabled.
    /// - Parameter enabled: A Boolean value indicating whether automatic check for updates is enabled.
    public func setAutomaticCheckForUpdatesEnabled(_ enabled: Bool) {
        guard automaticCheckForUpdatesEnabledSubject.value != enabled else { return }

        updaterController.sparkleUpdater.automaticallyChecksForUpdates = enabled
        automaticCheckForUpdatesEnabledSubject.send(enabled)
    }

    /// Sets whether automatic download updates is enabled.
    /// - Parameter enabled: A Boolean value indicating whether automatic download updates is enabled.
    public func setAutomaticDownloadUpdatesEnabled(_ enabled: Bool) {
        guard automaticDownloadUpdatesEnabledSubject.value != enabled else { return }

        updaterController.sparkleUpdater.automaticallyDownloadsUpdates = enabled
        automaticDownloadUpdatesEnabledSubject.send(enabled)
    }

    /// Manually checks for updates.
    public func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

// MARK: - Protocols

/// Protocol defining the interface for Sparkle updater.
@MainActor
public protocol SparkleUpdaterProtocol: AnyObject {
    var automaticallyChecksForUpdates: Bool { get set }
    var automaticallyDownloadsUpdates: Bool { get set }
    var lastUpdateCheckDate: Date? { get }

    func publisherForAutomaticallyChecksForUpdates() -> AnyPublisher<Bool, Never>
    func publisherForAutomaticallyDownloadsUpdates() -> AnyPublisher<Bool, Never>
    func publisherForLastUpdateCheckDate() -> AnyPublisher<Date?, Never>
}

/// Protocol defining the interface for Sparkle updater controller.
@MainActor
public protocol SparkleUpdaterControllerProtocol: AnyObject {
    var sparkleUpdater: SparkleUpdaterProtocol { get }

    func checkForUpdates(_ sender: Any?)
}

// MARK: - Extensions

extension SPUUpdater: SparkleUpdaterProtocol {
    public func publisherForAutomaticallyChecksForUpdates() -> AnyPublisher<Bool, Never> {
        publisher(for: \.automaticallyChecksForUpdates).eraseToAnyPublisher()
    }

    public func publisherForAutomaticallyDownloadsUpdates() -> AnyPublisher<Bool, Never> {
        publisher(for: \.automaticallyDownloadsUpdates).eraseToAnyPublisher()
    }

    public func publisherForLastUpdateCheckDate() -> AnyPublisher<Date?, Never> {
        publisher(for: \.lastUpdateCheckDate).eraseToAnyPublisher()
    }
}

extension SPUStandardUpdaterController: SparkleUpdaterControllerProtocol {
    public var sparkleUpdater: SparkleUpdaterProtocol {
        updater
    }
}
