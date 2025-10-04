// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Protocol defining the interface for spaces data operations.
///
/// This protocol provides a contract for repositories that manage spaces data,
/// allowing for easy testing and dependency injection. It belongs to the domain layer
/// and defines the business requirements for spaces operations.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
public protocol SpacesGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits spaces with their associated windows updates.
    var spacesWithWindowsPublisher: AnyPublisher<[Space], Never> { get }

    /// Publisher that emits AeroSpace running status updates.
    var aeroSpaceRunningPublisher: AnyPublisher<Bool, Never> { get }

    // MARK: - Async Operations (trigger updates via publishers)

    /// Focuses a specific space.
    /// - Parameters:
    ///   - spaceId: The identifier of the space to focus
    ///   - needWindowFocus: Whether to also focus a window in the space
    /// - Throws: AppError if the operation fails
    func focusSpace(spaceId: String, needWindowFocus: Bool) async throws

    /// Focuses a specific window.
    /// - Parameter windowId: The identifier of the window to focus
    /// - Throws: AppError if the operation fails
    func focusWindow(windowId: String) async throws

    /// Starts AeroSpace if it's not currently running.
    /// - Throws: AppError if starting AeroSpace fails
    func startAeroSpace() async throws
}
