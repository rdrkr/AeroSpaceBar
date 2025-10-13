// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI
import WebKit

/// A WebView component for displaying the license checkout flow.
///
/// This view wraps WKWebView to provide an embedded web browsing experience
/// for the license checkout process without requiring external browser navigation.
struct CheckoutWebViewWrapper: NSViewRepresentable {
    /// The URL to load in the web view.
    let url: URL

    /// Callback invoked when the web view should be dismissed.
    let onDismiss: () -> Void

    /// Callback invoked when checkout completes successfully with a license key.
    let onCheckoutSuccess: ((String) -> Void)?

    /// Creates and configures the WKWebView instance.
    /// - Parameter context: The NSViewRepresentable context
    /// - Returns: A configured WKWebView instance
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    /// Updates the WKWebView with new content if needed.
    /// - Parameters:
    ///   - nsView: The WKWebView instance to update
    ///   - context: The NSViewRepresentable context
    func updateNSView(_: WKWebView, context _: Context) {
        // No updates needed
    }

    /// Creates the coordinator that handles web view navigation events.
    /// - Returns: A Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss, onCheckoutSuccess: onCheckoutSuccess)
    }

    /// Coordinator class that handles WKWebView navigation events.
    ///
    /// This coordinator monitors navigation events to detect successful purchases
    /// and extracts the license key from the redirect URL.
    class Coordinator: NSObject, WKNavigationDelegate {
        /// Callback invoked when the web view should be dismissed.
        private let onDismiss: () -> Void

        /// Callback invoked when checkout completes successfully with a license key.
        private let onCheckoutSuccess: ((String) -> Void)?

        /// Initializes the coordinator with the dismiss and success callbacks.
        /// - Parameters:
        ///   - onDismiss: Callback to invoke when dismissing the web view
        ///   - onCheckoutSuccess: Callback to invoke with the license key on successful checkout
        init(onDismiss: @escaping () -> Void, onCheckoutSuccess: ((String) -> Void)?) {
            self.onDismiss = onDismiss
            self.onCheckoutSuccess = onCheckoutSuccess
        }

        // MARK: - WKNavigationDelegate

        /// Intercepts navigation actions to detect the success redirect URL.
        ///
        /// This method is called before each navigation to decide whether to allow it.
        /// When LemonSqueezy redirects to the success URL after payment, we extract the
        /// license key and trigger the success callback while allowing the page to load.
        ///
        /// - Parameters:
        ///   - webView: The web view requesting the navigation
        ///   - navigationAction: The navigation action containing the request
        ///   - preferences: The webpage preferences for the navigation
        ///   - decisionHandler: Handler to call with the navigation policy decision and preferences
        func webView(
            _: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            preferences: WKWebpagePreferences,
            decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow, preferences)
                return
            }

            // Check if this is the success redirect URL from LemonSqueezy
            // This happens after the user completes payment on the checkout page
            if
                url.host == "success.aerospacebar.app",
                url.path == "/checkout"
            {
                // Extract license key from URL parameters
                if
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                    let queryItems = components.queryItems,
                    let licenseKeyItem = queryItems.first(where: { $0.name == "license_key" }),
                    let licenseKey = licenseKeyItem.value,
                    !licenseKey.isEmpty
                {
                    Logger.info("Checkout completed successfully with license key", category: Logger.app)

                    // Allow the success page to load (avoids WebKit warnings)
                    decisionHandler(.allow, preferences)

                    // Call success callback with the license key and dismiss after brief delay
                    Task { @MainActor in
                        self.onCheckoutSuccess?(licenseKey)
                        // Brief delay to allow success page to show before closing
                        try? await Task.sleep(for: .seconds(0.5))
                        self.onDismiss()
                    }
                    return
                }
            }

            // Allow all other navigations (checkout page, payment forms, etc.)
            decisionHandler(.allow, preferences)
        }
    }
}

#Preview {
    CheckoutWebViewWrapper(
        url: URL(string: "https://www.example.com") ?? URL(fileURLWithPath: ""),
        onDismiss: { },
        onCheckoutSuccess: { licenseKey in
            print("License key received: \(licenseKey)")
        }
    )
    .frame(minWidth: 800, minHeight: 600)
}
