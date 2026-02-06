//
//  StickyUITestsLaunchTests.swift
//  StickyUITests
//
//  Created by 吉永悠記 on 2026/02/05.
//
//  Copyright (c) 2026 yuki
//
//  This software is released under the MIT License.
//  See LICENSE file for more information.
//

import XCTest

final class StickyUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
