// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving screen capture permission status.
///
/// This use case provides the current state of screen capture permissions.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
public final class GetScreenCapturePermissionGrantedUseCase {
    /// The system menu bar gateway for permission status.
    private let systemMenuBarGateway: SystemMenuBarGateway

    /// Initializes the use case with the system menu bar gateway.
    /// - Parameter systemMenuBarGateway: The gateway for screen capture permissions
    public init(systemMenuBarGateway: SystemMenuBarGateway) {
        self.systemMenuBarGateway = systemMenuBarGateway
    }

    /// Returns a publisher that emits updates to the screen capture permission status.
    /// - Returns: A publisher that emits permission status updates
    public func execute() -> AnyPublisher<Bool, Never> {
        systemMenuBarGateway.screenCapturePermissionGrantedPublisher
    }
}
