// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import Combine
    import Foundation

    /// Use case for retrieving the mockActiveLicense feature flag value (DEBUG builds only).
    ///
    /// This use case provides access to the current mockActiveLicense feature flag setting,
    /// allowing development and testing code to react to mock license flag changes.
    /// Only available in DEBUG builds.
    @MainActor
    public final class GetMockActiveLicenseUseCase {
        private let gateway: LicenseGateway

        /// Initializes the use case with a license feature flags gateway.
        /// - Parameter gateway: The gateway for accessing license feature flags
        public init(gateway: LicenseGateway) {
            self.gateway = gateway
        }

        /// Executes the use case to get the mockActiveLicense feature flag as a publisher.
        /// - Returns: A publisher that emits the current mockActiveLicense value
        public func execute() -> AnyPublisher<Bool, Never> {
            gateway.mockActiveLicensePublisher
        }
    }
#endif
