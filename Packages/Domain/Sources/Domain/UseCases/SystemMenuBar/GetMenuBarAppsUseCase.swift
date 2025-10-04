// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving menu bar applications.
///
/// This use case provides access to the list of applications that have icons
/// in the macOS system menu bar, following the clean architecture pattern.
@MainActor
public final class GetMenuBarAppsUseCase {
    /// The system menu bar gateway for accessing menu bar data.
    private let systemMenuBarGateway: SystemMenuBarGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter systemMenuBarGateway: The gateway for accessing system menu bar data
    public init(systemMenuBarGateway: SystemMenuBarGateway) {
        self.systemMenuBarGateway = systemMenuBarGateway
    }

    /// Gets a publisher that emits menu bar applications updates.
    /// - Returns: A publisher that emits arrays of MenuBarApp instances
    public func execute() -> AnyPublisher<[MenuBarApp], Never> {
        systemMenuBarGateway.menuBarAppsPublisher
    }
}
