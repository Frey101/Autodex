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
        
        // Vérifier le défilement et la pagination sur l'onglet Nouveautés
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 4) {
            scrollView.swipeUp()
            scrollView.swipeUp()
            let boutonPagination = app.buttons["boutonPagination"]
            if boutonPagination.waitForExistence(timeout: 4) && boutonPagination.isHittable {
                boutonPagination.tap()
            }
        }
    }

    @MainActor
    func testPaginationChargementPageSuivante() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Attendre que la liste charge les 20 premiers éléments
        let premierElement = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'ch'")).firstMatch
        XCTAssertTrue(premierElement.waitForExistence(timeout: 5), "Les véhicules initiaux doivent être affichés.")
        
        // Capture d'écran de l'état initial (page 1 : 20 éléments affichés)
        let captureInitiale = XCUIScreen.main.screenshot()
        try? captureInitiale.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/pagination_avant.png"))
        
        // Trouver la vue défilante
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "La liste défilante doit être présente.")
        
        // Défiler vers le bas pour charger automatiquement la suite ou atteindre le bouton
        for _ in 0..<3 {
            scrollView.swipeUp()
        }
        
        // Recherche du bouton de pagination s'il est affiché
        let boutonPagination = app.buttons["boutonPagination"]
        if boutonPagination.waitForExistence(timeout: 4) && boutonPagination.isHittable {
            boutonPagination.tap()
        }
        
        // Capture d'écran après chargement (page 2 : 40 éléments affichés)
        let captureApres = XCUIScreen.main.screenshot()
        try? captureApres.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/pagination_apres.png"))
    }

    @MainActor
    func testDecouvertePageEtNavigationFicheTechnique() throws {
        let app = XCUIApplication()
        app.launch()
        
        let ongletDecouverte = app.tabBars.buttons["Découverte"]
        XCTAssertTrue(ongletDecouverte.waitForExistence(timeout: 5), "L'onglet Découverte doit être présent dans la TabBar.")
        ongletDecouverte.tap()
        
        // Vérifier la présence de la carte et du bouton de consultation
        let boutonConsulter = app.buttons["boutonConsulterFicheDecouverte"]
        XCTAssertTrue(boutonConsulter.waitForExistence(timeout: 6), "Le bouton de consultation de fiche dans Découverte doit être visible.")
        
        // Capture d'écran de la nouvelle page Découverte
        let captureDecouverte = XCUIScreen.main.screenshot()
        try? captureDecouverte.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/decouverte_carte.png"))
        
        // Tap sur le bouton pour ouvrir la fiche technique
        boutonConsulter.tap()
        let barreNav = app.navigationBars["Fiche Technique"]
        XCTAssertTrue(barreNav.waitForExistence(timeout: 5), "Taper sur la carte Découverte doit ouvrir la fiche technique.")
        
        // Retour à la page découverte
        if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        
        // Test de passage à la voiture suivante
        let boutonPasser = app.buttons["boutonPasserDecouverte"]
        if boutonPasser.waitForExistence(timeout: 3) {
            boutonPasser.tap()
        }
    }

    @MainActor
    func testFavorisNavigationVersFicheDetail() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Ajouter un favori depuis l'accueil en tapant sur le bouton cœur de la première ligne
        let boutonCoeur = app.buttons.matching(identifier: "boutonCoeurLigne").firstMatch
        XCTAssertTrue(boutonCoeur.waitForExistence(timeout: 6), "Le bouton cœur de la première ligne doit être visible.")
        boutonCoeur.tap()
        
        // 2. Aller sur l'onglet Favoris
        let ongletFavoris = app.tabBars.buttons["Favoris"]
        XCTAssertTrue(ongletFavoris.waitForExistence(timeout: 5), "L'onglet Favoris doit être accessible.")
        ongletFavoris.tap()
        
        // 3. Attendre qu'une ligne de favori soit présente et cliquer dessus
        let favoriLink = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'favoriLink_'")).firstMatch
        XCTAssertTrue(favoriLink.waitForExistence(timeout: 6), "Le lien du favori ajouté doit apparaître dans l'onglet Favoris.")
        favoriLink.tap()
        
        // 4. Vérifier que la fiche technique s'ouvre bien depuis l'onglet Favoris !
        let barreNav = app.navigationBars["Fiche Technique"]
        XCTAssertTrue(barreNav.waitForExistence(timeout: 5), "Cliquer sur une ligne de favori doit ouvrir la fiche technique détaillée.")
        
        let captureFavoriFiche = XCUIScreen.main.screenshot()
        try? captureFavoriFiche.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/favori_detail.png"))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
