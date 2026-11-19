//
//  AutodexUITests.swift
//  AutodexUITests
//
//  Created by Alyssia Frey on 29/05/2026.
//

import XCTest

final class AutodexUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testNavigationVersFicheDetailEtWikipedia() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Attendre que les éléments de la liste apparaissent
        let premierElement = app.cells.firstMatch
        if premierElement.waitForExistence(timeout: 5) {
            premierElement.tap()
            
            // Vérifier que la vue détaillée s'ouvre bien
            let barreNav = app.navigationBars["Fiche Technique"]
            XCTAssertTrue(barreNav.waitForExistence(timeout: 5), "La fiche technique doit s'ouvrir au tap.")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
