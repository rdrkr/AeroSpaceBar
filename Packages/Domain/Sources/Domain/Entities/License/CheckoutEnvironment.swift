// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Represents the checkout environment for license purchases.
///
/// This allows switching between production and development checkout URLs
/// for testing purposes.
public enum CheckoutEnvironment: String, Codable, CaseIterable, Sendable {
    /// Production environment with real payment processing.
    case production

    /// Development/testing environment with test payment processing.
    case development

    /// Human-readable display name for the environment.
    public var displayName: String {
        switch self {
        case .production:
            "Production"

        case .development:
            "Development"
        }
    }
}
