// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI
import WebKit

/// A WebView component for displaying the license checkout flow.
///
/// This view wraps WKWebView to provide an embedded web browsing experience
/// for the Paddle checkout process without requiring external browser navigation.
struct CheckoutWebViewWrapper: NSViewRepresentable {
    /// The URL to load in the web view.
    let url: URL

    /// Callback invoked when the web view should be dismissed.
    let onDismiss: () -> Void

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
        Coordinator(onDismiss: onDismiss)
    }

    /// Coordinator class that handles WKWebView navigation events.
    ///
    /// This coordinator monitors navigation events to detect successful purchases
    /// or when the user should be redirected back to the main application.
    class Coordinator: NSObject, WKNavigationDelegate {
        /// Callback invoked when the web view should be dismissed.
        private let onDismiss: () -> Void

        /// Initializes the coordinator with the dismiss callback.
        /// - Parameter onDismiss: Callback to invoke when dismissing the web view
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        /// Handles successful navigation completion.
        /// - Parameters:
        ///   - webView: The web view that finished loading
        ///   - navigation: The navigation that finished
        func webView(_ webView: WKWebView, didFinish _: WKNavigation?) {
            if let currentURL = webView.url?.absoluteString {
                if currentURL.contains("success") || currentURL.contains("complete") {
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(2.0))
                        self.onDismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CheckoutWebViewWrapper(
        url: URL(string: "https://www.example.com") ?? URL(fileURLWithPath: ""),
        onDismiss: { }
    )
    .frame(minWidth: 800, minHeight: 600)
}
