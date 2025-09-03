// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Data Transfer Object for Space data from AeroSpace CLI.
///
/// This struct represents the raw JSON structure returned by the AeroSpace CLI
/// for space information. It's used to decode the CLI response before
/// mapping to domain entities.
struct SpaceData: Codable {
    /// The unique identifier of the space.
    let workspace: String

    /// Maps this DTO to a domain Space entity.
    /// - Returns: A domain Space entity
    func toDomain() -> Space {
        Space(id: workspace)
    }
}
