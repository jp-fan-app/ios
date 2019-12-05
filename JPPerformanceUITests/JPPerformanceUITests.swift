//
//  JPPerformanceUITests.swift
//  JPPerformanceUITests
//
//  Created by Christoph Pageler on 18.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import XCTest
import SimulatorStatusMagiciOS


class JPPerformanceUITests: XCTestCase {
    
    var app: XCUIApplication?
    
    override func setUp() {
        super.setUp()

        SDStatusBarManager.sharedInstance()?.enableOverrides()

        let newApp = XCUIApplication()
        newApp.launchArguments.append("TAKING_SCREENSHOTS")
        setupSnapshot(newApp)
        newApp.launch()
        
        self.app = newApp
    }

    func testBoard() {
        guard let app = self.app else { return }
        sleep(2)
        app.tabBars.buttons["board"].tap()
        sleep(2)
        snapshot("01_Board")
    }

    func testLaSiSe() {
        guard let app = self.app else { return }
        sleep(2)
        app.tabBars.buttons["lasise"].tap()
        sleep(2)
        snapshot("02_LaSiSe")
    }

    func testCarsDetail() {
        guard let app = self.app else { return }
        sleep(2)
        app.tabBars.buttons["cars"].tap()
        sleep(2)
        app.cells["carItemCell_0_0"].tap()
        sleep(2)
        snapshot("03_Cars_Detail")
    }

    func testCarsCompare() {
        guard let app = self.app else { return }
        sleep(2)
        app.tabBars.buttons["cars"].tap()
        sleep(2)
        app.cells["carItemCell_0_0"].tap()
        sleep(2)
        app.buttons["compare"].tap()
        app.buttons["select"].tap()
        app.cells["carItemCell_0_3"].tap()
        sleep(2)
        snapshot("04_Cars_Compare")
    }

    func testYoutubeList() {
        guard let app = self.app else { return }
        sleep(2)
        app.tabBars.buttons["youtube"].tap()
        sleep(2)
        snapshot("05_Youtube_List")
    }

    func testYoutubeDetail() {
        guard let app = self.app else { return }
        sleep(2)
        app.tabBars.buttons["youtube"].tap()
        sleep(2)
        app.cells["youtubeItemCell_0"].tap()
        sleep(2)
        snapshot("06_Youtube_Detail")
    }

    func testInfo() {
        guard let app = self.app else { return }
        sleep(2)
        app.navigationBars["Board"].children(matching: .button).element.tap()
        sleep(2)
        snapshot("07_Info")
    }

    func testInfoNotifications() {
        guard let app = self.app else { return }
        sleep(2)
        app.navigationBars["Board"].children(matching: .button).element.tap()
        sleep(2)
        app.buttons["notifications"].tap()
        snapshot("08_Info_Notifications")
    }

    func testSeriesList() {
        guard let app = self.app else { return }
        sleep(2)
        app.tabBars.buttons["series"].tap()
        sleep(2)
        snapshot("09_SeriesList")
    }

}
