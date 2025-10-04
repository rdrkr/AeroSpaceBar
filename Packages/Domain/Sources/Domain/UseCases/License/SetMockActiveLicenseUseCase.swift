// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import Foundation

    /// Use case for setting the mockActiveLicense feature flag value (DEBUG builds only).
    ///
    /// This use case handles updating the mockActiveLicense feature flag setting,
    /// ensuring the change is properly persisted and propagated through the system.
    /// Only available in DEBUG builds.
    @MainActor
    public final class SetMockActiveLicenseUseCase {
        private let gateway: LicenseGateway

        /// Initializes the use case with a license feature flags gateway.
        /// - Parameter gateway: The gateway for accessing license feature flags
        public init(gateway: LicenseGateway) {
            self.gateway = gateway
        }

        /// Executes the use case to set the mockActiveLicense feature flag value.
        /// - Parameter enabled: Whether an active license should be mocked
        public func execute(enabled: Bool) {
            gateway.setMockActiveLicense(enabled)
        }
    }
#endif
