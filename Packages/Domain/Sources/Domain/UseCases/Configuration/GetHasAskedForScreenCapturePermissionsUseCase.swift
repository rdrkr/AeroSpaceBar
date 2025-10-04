// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving whether the user has been asked for screen capture permissions.
///
/// Exposes a publisher of Bool reflecting the current state.
@MainActor
public final class GetHasAskedForScreenCapturePermissionsUseCase {
    private let configurationGateway: ConfigurationGateway

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get whether the user has been asked for screen capture permissions.
    public func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.hasAskedForScreenCapturePermissionsPublisher
    }
}
