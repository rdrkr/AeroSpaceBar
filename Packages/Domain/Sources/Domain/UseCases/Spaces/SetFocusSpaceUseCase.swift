// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting focus to a specific space.
///
/// This use case encapsulates the business logic for switching to and focusing a space.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
public final class SetFocusSpaceUseCase {
    /// The spaces gateway for data access.
    private let spacesGateway: SpacesGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter spacesGateway: The gateway for spaces data access
    public init(spacesGateway: SpacesGateway) {
        self.spacesGateway = spacesGateway
    }

    /// Executes the use case to set focus to a specific space.
    /// - Parameters:
    ///   - spaceId: The identifier of the space to focus
    ///   - needWindowFocus: Whether to also focus a window in the space
    /// - Throws: AppError if the operation fails
    public func execute(spaceId: String, needWindowFocus: Bool = false) async throws {
        try await spacesGateway.focusSpace(spaceId: spaceId, needWindowFocus: needWindowFocus)
    }
}
