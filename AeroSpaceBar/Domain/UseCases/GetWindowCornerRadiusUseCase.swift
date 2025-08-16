// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import SwiftUI

/// Use case for retrieving the window corner radius configuration.
///
/// This use case encapsulates the business logic for retrieving the window corner radius
/// from the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
final class GetWindowCornerRadiusUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the window corner radius setting as a publisher.
    /// - Returns: A publisher that emits window corner radius values
    func execute() -> AnyPublisher<CGFloat, Never> {
        configurationGateway.windowCornerRadiusPublisher
    }
}
