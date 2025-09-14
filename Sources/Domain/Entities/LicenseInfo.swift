// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// License information from Paddle.
public struct LicenseInfo {
    /// The license key.
    public let licenseKey: String

    /// The customer email associated with the license.
    public let customerEmail: String

    /// Whether the license is active.
    public let isActive: Bool

    /// The product ID from Paddle.
    public let productId: String

    /// The transaction ID from Paddle.
    public let transactionId: String?

    /// The expiration date (if applicable).
    public let expirationDate: Date?

    public init(
        licenseKey: String,
        customerEmail: String,
        isActive: Bool,
        productId: String,
        transactionId: String? = nil,
        expirationDate: Date? = nil
    ) {
        self.licenseKey = licenseKey
        self.customerEmail = customerEmail
        self.isActive = isActive
        self.productId = productId
        self.transactionId = transactionId
        self.expirationDate = expirationDate
    }
}
