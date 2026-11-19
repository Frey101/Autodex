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
    func testRechercheDynamiqueFrappeEtEffacement() throws {
        let app = XCUIApplication()
        app.launch()
        
        let champRecherche = app.textFields["Rechercher un modèle (ex: clio, mustang...)"]
        XCTAssertTrue(champRecherche.waitForExistence(timeout: 5), "La barre de recherche doit être visible.")
        
        // 1. Frappe dynamique
        champRecherche.tap()
        champRecherche.typeText("911")
        
        // Vérification de la mise à jour dynamique de la liste
        let textePorsche = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '911'")).firstMatch
        XCTAssertTrue(textePorsche.waitForExistence(timeout: 4), "La liste doit afficher les résultats dynamiquement dès la saisie.")
        
        // 2. Bouton d'effacement
        let boutonEffacer = app.buttons["Effacer la recherche"]
        if boutonEffacer.waitForExistence(timeout: 2) {
            boutonEffacer.tap()
            XCTAssertEqual(champRecherche.value as? String, "Rechercher un modèle (ex: clio, mustang...)", "Le champ doit être réinitialisé.")
        }
    }

    @MainActor
    func testOngletNouveautes() throws {
        let app = XCUIApplication()
        app.launch()
        
        let boutonNouveautes = app.buttons["Nouveautés"]
        XCTAssertTrue(boutonNouveautes.waitForExistence(timeout: 5), "Le bouton Nouveautés doit exister.")
        boutonNouveautes.tap()
        
        // Vérifier qu'un véhicule récent (2025 ou 2026) apparaît
        let texteRecent = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '2025' OR label CONTAINS '2026'")).firstMatch
        XCTAssertTrue(texteRecent.waitForExistence(timeout: 4), "L'onglet Nouveautés doit afficher des modèles récents 2025-2026.")
        
        // Sauvegarder la capture d'écran pour vérification visuelle
        let capture = XCUIScreen.main.screenshot()
        try? capture.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/nouveautes.png"))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
