// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import SwiftUI

/// Use case for getting the space border width setting.
@MainActor
public final class GetSpaceBorderWidthUseCase {
    /// The configuration gateway for accessing border width data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the space border width setting.
    /// - Returns: A publisher that emits the current border width value
    public func execute() -> AnyPublisher<Double, Never> {
        configurationGateway.spaceBorderWidthPublisher
    }
}
