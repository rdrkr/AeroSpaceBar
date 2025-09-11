// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import SwiftUI

/// Use case for retrieving the window icon size configuration.
///
/// This use case encapsulates the business logic for retrieving the window icon size
/// from the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
public final class GetWindowIconSizeUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the window icon size setting as a publisher.
    /// - Returns: A publisher that emits window icon size values
    public func execute() -> AnyPublisher<CGFloat, Never> {
        configurationGateway.windowIconSizePublisher
    }
}
