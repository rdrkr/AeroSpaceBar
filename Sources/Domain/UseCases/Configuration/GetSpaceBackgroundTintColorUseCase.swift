// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import SwiftUI

/// Use case for getting space background tint color setting.
///
/// This use case encapsulates the business logic for retrieving the
/// space background tint color configuration from the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.

@MainActor
public final class GetSpaceBackgroundTintColorUseCase {
    /// The configuration gateway for accessing space background tint color data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the space background tint color setting.
    /// - Returns: A publisher that emits the current space background tint color value

    public func execute() -> AnyPublisher<Color, Never> {
        configurationGateway.spaceBackgroundTintColorPublisher
    }
}
