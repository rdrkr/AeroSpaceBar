// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for getting system menu bar visibility status.
///
/// This use case provides reactive access to menu bar visibility changes,
/// allowing the UI to respond when the system menu bar is shown or hidden.
/// It follows the reactive pattern for consistent data flow.
@MainActor
public final class GetMenuBarVisibilityUseCase {
    /// The system menu bar gateway dependency.
    private let systemMenuBarGateway: SystemMenuBarGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter systemMenuBarGateway: Gateway for system menu bar operations
    public init(systemMenuBarGateway: SystemMenuBarGateway) {
        self.systemMenuBarGateway = systemMenuBarGateway
    }

    /// Executes the use case to get menu bar visibility updates.
    /// - Returns: A publisher that emits menu bar visibility changes
    public func execute() -> AnyPublisher<Bool, Never> {
        systemMenuBarGateway.menuBarVisibilityPublisher
    }
}
