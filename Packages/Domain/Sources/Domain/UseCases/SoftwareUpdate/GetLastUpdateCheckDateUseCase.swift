// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the last update check date.
///
/// Exposes a publisher of optional Date reflecting when updates were last checked.
@MainActor
public final class GetLastUpdateCheckDateUseCase {
    private let softwareUpdateGateway: SoftwareUpdateGateway

    public init(softwareUpdateGateway: SoftwareUpdateGateway) {
        self.softwareUpdateGateway = softwareUpdateGateway
    }

    /// Executes the use case to get the last update check date as a publisher.
    /// - Returns: A publisher that emits the last update check date, or nil if never checked.
    public func execute() -> AnyPublisher<Date?, Never> {
        softwareUpdateGateway.lastUpdateCheckDatePublisher
    }
}
