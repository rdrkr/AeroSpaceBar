// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import Nimble
@testable import Presentation
import XCTest

/// Verifies that spaces panels observe independent menu bar state while sharing workspace data.
@MainActor
final class DisplayMenuBarViewModelTests: XCTestCase {
    func testReadsInitialDisplayState() {
        let wallpaper = NSImage(size: NSSize(width: 120, height: 24))
        let gateway = MockSystemMenuBarGateway(
            menuBarHeight: 24,
            menuBarVisibility: false,
            wallpaper: wallpaper
        )
        let viewModel = makeViewModel(gateway: gateway)

        expect(viewModel.wallpaper === wallpaper) == true
        expect(viewModel.menuBarHeight) == 24
        expect(viewModel.isMenuBarVisible) == false
    }

    func testDisplayUpdatesDoNotAffectOtherPanels() {
        let firstGateway = MockSystemMenuBarGateway(menuBarHeight: 24)
        let secondGateway = MockSystemMenuBarGateway(menuBarHeight: 32)
        let first = makeViewModel(gateway: firstGateway)
        let second = makeViewModel(gateway: secondGateway)
        let wallpaper = NSImage(size: NSSize(width: 120, height: 40))

        firstGateway.setWallpaper(wallpaper)
        firstGateway.setMenuBarHeight(40)
        firstGateway.setMenuBarVisibility(false)

        expect(first.wallpaper === wallpaper) == true
        expect(first.menuBarHeight) == 40
        expect(first.isMenuBarVisible) == false
        expect(second.wallpaper).to(beNil())
        expect(second.menuBarHeight) == 32
        expect(second.isMenuBarVisible) == true
    }

    private func makeViewModel(gateway: SystemMenuBarGateway) -> DisplayMenuBarViewModel {
        DisplayMenuBarViewModel(
            getWallpaperUseCase: GetWallpaperUseCase(systemMenuBarGateway: gateway),
            getMenuBarHeightUseCase: GetMenuBarHeightUseCase(systemMenuBarGateway: gateway),
            getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase(systemMenuBarGateway: gateway)
        )
    }
}
