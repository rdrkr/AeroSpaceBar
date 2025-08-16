// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting focus to a specific window.
///
/// This use case encapsulates the business logic for switching to and focusing a window.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
final class SetFocusWindowUseCase {
    /// The spaces gateway for data access.
    private let spacesGateway: SpacesGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter spacesGateway: The gateway for spaces data access
    init(spacesGateway: SpacesGateway) {
        self.spacesGateway = spacesGateway
    }

    /// Executes the use case to set focus to a specific window.
    /// - Parameter windowId: The identifier of the window to focus
    /// - Throws: AppError if the operation fails
    func execute(windowId: String) async throws {
        try await spacesGateway.focusWindow(windowId: windowId)
    }
}
