// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving spaces data.
///
/// This use case encapsulates the business logic for fetching spaces and their associated windows.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
final class GetSpacesUseCase {
    /// The spaces gateway for data access.
    private let spacesGateway: SpacesGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter spacesRepository: The gateway for spaces data access
    init(spacesGateway: SpacesGateway) {
        self.spacesGateway = spacesGateway
    }

    /// Executes the use case to retrieve spaces data as a publisher.
    /// - Returns: A publisher that emits spaces with their associated windows
    func execute() -> AnyPublisher<[Space], Never> {
        spacesGateway.spacesWithWindowsPublisher
    }
}
