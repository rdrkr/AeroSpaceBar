// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for starting AeroSpace if it's not running.
///
/// This use case handles launching the AeroSpace window manager when it's not currently running,
/// following the domain-driven design pattern by delegating to the SpacesGateway.
@MainActor
public final class StartAeroSpaceUseCase {
    /// The spaces gateway for performing AeroSpace operations.
    private let spacesGateway: SpacesGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter spacesGateway: The gateway for spaces operations
    public init(spacesGateway: SpacesGateway) {
        self.spacesGateway = spacesGateway
    }

    /// Executes the use case to start AeroSpace if it's not running.
    ///
    /// This method delegates to the SpacesGateway to start AeroSpace,
    /// following Clean Architecture principles.
    /// - Throws: AppError if starting AeroSpace fails
    public func execute() async throws {
        try await spacesGateway.startAeroSpace()
    }
}
