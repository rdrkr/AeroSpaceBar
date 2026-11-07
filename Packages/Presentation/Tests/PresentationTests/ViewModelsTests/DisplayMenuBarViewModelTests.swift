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

    func testAppleButtonFrameFollowsItsDisplay() {
        let firstGateway = MockSystemMenuBarGateway(menuBarHeight: 24)
        let secondGateway = MockSystemMenuBarGateway(menuBarHeight: 32)
        let first = makeViewModel(gateway: firstGateway)
        let second = makeViewModel(gateway: secondGateway)
        let frame = CGRect(x: 8, y: 0, width: 39, height: 32)

        secondGateway.setAppleButtonFrame(frame)

        expect(first.appleButtonFrame) == .zero
        expect(second.appleButtonFrame) == frame
    }

    func testPrimaryDisplayKeepsStatusItemFrames() {
        let viewModel = makeViewModel(gateway: MockSystemMenuBarGateway(menuBarHeight: 30))
        let apps = [MenuBarApp(id: "item", frame: CGRect(x: 2_810, y: 0, width: 17, height: 30))]

        expect(viewModel.localMenuBarApps(from: apps)) == apps
    }

    func testProjectsStatusItemsFromTheRightEdgeOfTheDisplay() {
        let viewModel = makeViewModel(gateway: MockSystemMenuBarGateway(menuBarHeight: 39))
        viewModel.statusItemsGeometry = .init(primaryWidth: 3_008, displayWidth: 1_800, minX: 0)
        let apps = [MenuBarApp(id: "item", frame: CGRect(x: 2_810, y: 0, width: 17, height: 30))]

        expect(viewModel.localMenuBarApps(from: apps)) == [
            MenuBarApp(id: "item", frame: CGRect(x: 1_602, y: 0, width: 17, height: 39))
        ]
    }

    func testClipsStatusItemsHiddenBehindTheCameraHousing() {
        let viewModel = makeViewModel(gateway: MockSystemMenuBarGateway(menuBarHeight: 39))
        viewModel.statusItemsGeometry = .init(primaryWidth: 3_008, displayWidth: 1_800, minX: 1_010)
        let apps = [
            MenuBarApp(id: "partial", frame: CGRect(x: 2_200, y: 0, width: 40, height: 30)),
            MenuBarApp(id: "hidden", frame: CGRect(x: 2_100, y: 0, width: 40, height: 30))
        ]

        expect(viewModel.localMenuBarApps(from: apps).map(\.frame)) == [
            CGRect(x: 1_010, y: 0, width: 22, height: 39),
            CGRect(x: 1_010, y: 0, width: 0, height: 39)
        ]
    }

    private func makeViewModel(gateway: SystemMenuBarGateway) -> DisplayMenuBarViewModel {
        DisplayMenuBarViewModel(
            getWallpaperUseCase: GetWallpaperUseCase(systemMenuBarGateway: gateway),
            getMenuBarHeightUseCase: GetMenuBarHeightUseCase(systemMenuBarGateway: gateway),
            getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase(systemMenuBarGateway: gateway),
            getAppleButtonFrameUseCase: GetAppleButtonFrameUseCase(systemMenuBarGateway: gateway)
        )
    }
}
