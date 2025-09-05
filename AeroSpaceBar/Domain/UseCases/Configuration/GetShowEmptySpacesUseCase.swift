// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the show-empty-spaces setting.
///
/// Exposes a publisher of Bool reflecting the current configuration state.
@MainActor
final class GetShowEmptySpacesUseCase {
    private let configurationGateway: ConfigurationGateway

    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the show-empty-spaces setting as a publisher.
    func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.showEmptySpacesPublisher
    }
}
