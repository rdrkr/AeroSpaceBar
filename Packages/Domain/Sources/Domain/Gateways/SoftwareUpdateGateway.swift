// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Protocol defining the interface for software update operations.
///
/// This protocol provides a contract for repositories that manage software updates,
/// allowing for easy testing and dependency injection. It belongs to the domain layer
/// and defines the business requirements for update operations.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
public protocol SoftwareUpdateGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits automatic check for updates enabled state updates.
    var automaticCheckForUpdatesEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits automatic download updates enabled state updates.
    var automaticDownloadUpdatesEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits the last update check date.
    var lastUpdateCheckDatePublisher: AnyPublisher<Date?, Never> { get }

    // MARK: - Async Setters (trigger updates via publishers)

    /// Sets whether automatic checking for updates is enabled.
    /// - Parameter enabled: Whether to enable automatic update checks.
    func setAutomaticCheckForUpdatesEnabled(_ enabled: Bool) async

    /// Sets whether automatic downloading of updates is enabled.
    /// - Parameter enabled: Whether to enable automatic update downloads.
    func setAutomaticDownloadUpdatesEnabled(_ enabled: Bool) async

    /// Manually checks for available updates.
    func checkForUpdates() async
}
