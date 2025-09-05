// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import SwiftUI

/// Use case for retrieving the menu bar height configuration.
///
/// This use case encapsulates the business logic for retrieving the menu bar height
/// from the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
final class GetMenuBarHeightUseCase {
    /// The system menu bar gateway for capturing wallpaper and tracking menu bar.
    private let systemMenuBarGateway: SystemMenuBarGateway

    /// Initializes the use case with the system menu bar gateway.
    /// - Parameter systemMenuBarGateway: The gateway for accessing system menu bar data
    init(systemMenuBarGateway: SystemMenuBarGateway) {
        self.systemMenuBarGateway = systemMenuBarGateway
    }

    /// Executes the use case to get the menu bar height setting as a publisher.
    /// - Returns: A publisher that emits menu bar height values
    func execute() -> AnyPublisher<CGFloat, Never> {
        systemMenuBarGateway.menuBarHeightPublisher
    }
}
