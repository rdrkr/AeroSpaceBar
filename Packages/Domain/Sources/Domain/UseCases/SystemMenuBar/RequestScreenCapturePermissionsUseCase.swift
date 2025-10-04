// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for requesting screen capture permissions.
///
/// This use case handles the logic for requesting screen capture permissions from the user.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
public final class RequestScreenCapturePermissionsUseCase {
    /// The system menu bar gateway for permission requests.
    private let systemMenuBarGateway: SystemMenuBarGateway

    /// Initializes the use case with the system menu bar gateway.
    /// - Parameter systemMenuBarGateway: The gateway for screen capture permissions
    public init(systemMenuBarGateway: SystemMenuBarGateway) {
        self.systemMenuBarGateway = systemMenuBarGateway
    }

    /// Executes the use case to request screen capture permissions.
    public func execute() async {
        await systemMenuBarGateway.requestScreenCapturePermissions()
    }
}
