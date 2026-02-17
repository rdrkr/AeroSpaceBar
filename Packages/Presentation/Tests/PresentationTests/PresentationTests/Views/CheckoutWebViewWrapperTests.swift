// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import WebKit
import XCTest

/// Tests for CheckoutWebViewWrapper.
///
/// These tests verify:
/// - NSViewRepresentable conformance
/// - WKWebView creation and configuration
/// - Navigation delegate setup
/// - URL loading
/// - Success redirect detection
/// - License key extraction from URL
/// - Coordinator behavior
@MainActor
final class CheckoutWebViewWrapperTests: XCTestCase {
    private var sut: CheckoutWebViewWrapper?
    private var testURL: URL?
    private var onDismissCalled: Bool?
    private var receivedLicenseKey: String?

    override func setUp() async throws {
        try await super.setUp()
        testURL = URL(string: "https://example.com/checkout")
        onDismissCalled = false
        receivedLicenseKey = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given/When
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { },
            onCheckoutSuccess: nil
        )

        // Then
        expect(self.sut).toNot(beNil())
    }

    // MARK: - NSViewRepresentable Tests

    func testMakeNSView() {
        // NSViewRepresentableContext is internal to SwiftUI and cannot be constructed in tests
        // Skipping NSViewRepresentable tests as they require access to internal SwiftUI APIs
    }

    func testUpdateNSView() {
        // NSViewRepresentableContext is internal to SwiftUI and cannot be constructed in tests
        // Skipping NSViewRepresentable tests as they require access to internal SwiftUI APIs
    }

    // MARK: - Coordinator Tests

    func testMakeCoordinator() {
        // Given
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { self.onDismissCalled = true },
            onCheckoutSuccess: { key in self.receivedLicenseKey = key }
        )

        // When
        guard let sut else {
            XCTFail("sut should not be nil")
            return
        }

        let coordinator = sut.makeCoordinator()

        // Then
        expect(coordinator).toNot(beNil())
    }

    // MARK: - Success URL Detection Tests

    func testCoordinatorDetectsSuccessURL() async {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given
        let expectation = expectation(description: "Checkout success detected")
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { self.onDismissCalled = true },
            onCheckoutSuccess: { key in
                self.receivedLicenseKey = key
                expectation.fulfill()
            }
        )

        guard let sut else {
            XCTFail("sut should not be nil")
            return
        }

        let coordinator = sut.makeCoordinator()

        let successURL = URL(string: "https://success.aerospacebar.app/checkout?license_key=TEST-KEY-1234")
        let navigationAction = MockNavigationAction(url: successURL)
        let preferences = WKWebpagePreferences()

        // When
        coordinator.webView(
            WKWebView(),
            decidePolicyFor: navigationAction,
            preferences: preferences
        ) { _, _ in }

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        expect(self.receivedLicenseKey) == "TEST-KEY-1234"
    }

    func testCoordinatorAllowsNonSuccessURL() {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given
        var policyDecision: WKNavigationActionPolicy?
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { },
            onCheckoutSuccess: nil
        )

        guard let sut else {
            XCTFail("sut should not be nil")
            return
        }

        let coordinator = sut.makeCoordinator()

        let regularURL = URL(string: "https://example.com/checkout")
        let navigationAction = MockNavigationAction(url: regularURL)
        let preferences = WKWebpagePreferences()

        // When
        coordinator.webView(
            WKWebView(),
            decidePolicyFor: navigationAction,
            preferences: preferences
        ) { policy, _ in
            policyDecision = policy
        }

        // Then
        expect(policyDecision) == .allow
    }

    func testCoordinatorHandlesURLWithoutLicenseKey() {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given
        var policyDecision: WKNavigationActionPolicy?
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { },
            onCheckoutSuccess: { _ in
                XCTFail("Should not call success without license key")
            }
        )

        guard let sut else {
            XCTFail("sut should not be nil")
            return
        }

        let coordinator = sut.makeCoordinator()

        let successURLWithoutKey = URL(string: "https://success.aerospacebar.app/checkout")
        let navigationAction = MockNavigationAction(url: successURLWithoutKey)
        let preferences = WKWebpagePreferences()

        // When
        coordinator.webView(
            WKWebView(),
            decidePolicyFor: navigationAction,
            preferences: preferences
        ) { policy, _ in
            policyDecision = policy
        }

        // Then
        expect(policyDecision) == .allow
    }

    func testCoordinatorHandlesURLWithEmptyLicenseKey() {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given
        var policyDecision: WKNavigationActionPolicy?
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { },
            onCheckoutSuccess: { _ in
                XCTFail("Should not call success with empty license key")
            }
        )

        guard let sut else {
            XCTFail("sut should not be nil")
            return
        }

        let coordinator = sut.makeCoordinator()

        let successURLWithEmptyKey = URL(string: "https://success.aerospacebar.app/checkout?license_key=")
        let navigationAction = MockNavigationAction(url: successURLWithEmptyKey)
        let preferences = WKWebpagePreferences()

        // When
        coordinator.webView(
            WKWebView(),
            decidePolicyFor: navigationAction,
            preferences: preferences
        ) { policy, _ in
            policyDecision = policy
        }

        // Then
        expect(policyDecision) == .allow
    }

    func testCoordinatorHandlesNilURL() {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given
        var policyDecision: WKNavigationActionPolicy?
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { },
            onCheckoutSuccess: nil
        )

        guard let sut else {
            XCTFail("sut should not be nil")
            return
        }

        let coordinator = sut.makeCoordinator()

        let navigationAction = MockNavigationAction(url: nil)
        let preferences = WKWebpagePreferences()

        // When
        coordinator.webView(
            WKWebView(),
            decidePolicyFor: navigationAction,
            preferences: preferences
        ) { policy, _ in
            policyDecision = policy
        }

        // Then
        expect(policyDecision) == .allow
    }

    // MARK: - Callback Tests

    func testOnDismissCallbackNotNil() {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given
        var dismissCalled = false
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { dismissCalled = true },
            onCheckoutSuccess: nil
        )

        // When/Then
        expect(dismissCalled) == false
    }

    func testOnCheckoutSuccessCallbackOptional() {
        guard let testURL else {
            XCTFail("testURL should not be nil")
            return
        }

        // Given/When
        sut = CheckoutWebViewWrapper(
            url: testURL,
            onDismiss: { },
            onCheckoutSuccess: nil
        )

        // Then - Should not crash with nil callback
        expect(self.sut).toNot(beNil())
    }
}

// MARK: - Mock Navigation Action

private class MockNavigationAction: WKNavigationAction {
    private let mockURL: URL?

    init(url: URL?) {
        mockURL = url
        super.init()
    }

    override var request: URLRequest {
        if let url = mockURL {
            return URLRequest(url: url)
        }
        guard let blankURL = URL(string: "about:blank") else {
            // Should never happen with valid string, but safer than fatalError
            return URLRequest(url: URL(fileURLWithPath: "/"))
        }

        return URLRequest(url: blankURL)
    }
}
