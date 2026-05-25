// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the hidden-spaces setting.
///
/// Exposes a publisher of `[String]` reflecting the currently hidden space IDs.
@MainActor
public final class GetHiddenSpacesUseCase {
    private let configurationGateway: ConfigurationGateway

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the hidden-spaces setting as a publisher.
    public func execute() -> AnyPublisher<[String], Never> {
        configurationGateway.hiddenSpacesPublisher
    }
}
