// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the Apple Button (Apple menu icon) frame.
///
/// This use case provides access to the Apple Button frame detected
/// in the macOS system menu bar, following the clean architecture pattern.
@MainActor
public final class GetAppleButtonFrameUseCase {
    /// The system menu bar gateway for accessing menu bar data.
    private let systemMenuBarGateway: SystemMenuBarGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter systemMenuBarGateway: The gateway for accessing system menu bar data
    public init(systemMenuBarGateway: SystemMenuBarGateway) {
        self.systemMenuBarGateway = systemMenuBarGateway
    }

    /// Gets a publisher that emits Apple Button frame updates.
    /// - Returns: A publisher that emits CGRect instances representing the Apple Button frame
    public func execute() -> AnyPublisher<CGRect, Never> {
        systemMenuBarGateway.appleButtonFramePublisher
    }
}
