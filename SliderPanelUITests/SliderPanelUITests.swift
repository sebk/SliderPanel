//
//  SliderPanelUITests.swift
//  SliderPanelUITests
//
//  Created by Sebastian Kruschwitz on 31.01.18.
//  Copyright © 2018 seb. All rights reserved.
//

import XCTest

// http://masilotti.com/ui-testing-cheat-sheet/
class SliderPanelUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOpenLeftPanel() {
        let tableView = app.tables.containing(.table, identifier: "Content Table left")
        let window = app.windows.element(boundBy: 0)
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        
        element.children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 1).tap()
        
        XCTAssert(window.frame.contains(tableView.element.frame))
    }
    
    func testClosePanel() {
        let tableView = app.tables.containing(.table, identifier: "Content Table left")
        let window = app.windows.element(boundBy: 0)
        let element = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        
        element.children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 1).tap()
        element.children(matching: .button).element(boundBy: 0).tap()
        
        XCTAssertFalse(window.frame.contains(tableView.element.frame))
    }
    
}
