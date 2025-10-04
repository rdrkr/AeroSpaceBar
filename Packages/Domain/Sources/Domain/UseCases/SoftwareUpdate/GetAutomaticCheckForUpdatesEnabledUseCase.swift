// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the automatic check for updates enabled setting.
///
/// Exposes a publisher of Bool reflecting the current automatic update check state.
@MainActor
public final class GetAutomaticCheckForUpdatesEnabledUseCase {
    private let softwareUpdateGateway: SoftwareUpdateGateway

    public init(softwareUpdateGateway: SoftwareUpdateGateway) {
        self.softwareUpdateGateway = softwareUpdateGateway
    }

    /// Executes the use case to get the automatic check for updates enabled setting as a publisher.
    /// - Returns: A publisher that emits the current automatic check for updates enabled state.
    public func execute() -> AnyPublisher<Bool, Never> {
        softwareUpdateGateway.automaticCheckForUpdatesEnabledPublisher
    }
}
