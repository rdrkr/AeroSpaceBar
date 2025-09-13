// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import SwiftUI

/// Use case for retrieving the widget spacing configuration.
///
/// This use case encapsulates the business logic for retrieving the widget spacing
/// from the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
public final class GetWidgetSpacingUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the widget spacing setting as a publisher.
    /// - Returns: A publisher that emits widget spacing values
    public func execute() -> AnyPublisher<Double, Never> {
        configurationGateway.widgetSpacingPublisher
    }
}
