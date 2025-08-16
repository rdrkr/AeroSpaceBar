// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for getting AeroSpace running status.
///
/// This use case encapsulates the business logic for determining if AeroSpace is currently running.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
final class GetAeroSpaceStatusUseCase {
    /// The spaces gateway for data access.
    private let spacesGateway: SpacesGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter spacesGateway: The gateway for spaces data access
    init(spacesGateway: SpacesGateway) {
        self.spacesGateway = spacesGateway
    }

    /// Executes the use case to get AeroSpace status as a publisher.
    /// - Returns: A publisher that emits AeroSpace running status
    func execute() -> AnyPublisher<Bool, Never> {
        spacesGateway.aeroSpaceRunningPublisher
    }
}
