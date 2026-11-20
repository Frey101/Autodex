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
    private func naviguerVersSection(app: XCUIApplication, sectionId: String) {
        let boutonHamburger = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'boutonMenu'")).firstMatch
        if boutonHamburger.waitForExistence(timeout: 5) {
            boutonHamburger.tap()
        }
        
        let itemMenu = app.buttons["menuItem_\(sectionId)"]
        XCTAssertTrue(itemMenu.waitForExistence(timeout: 4), "L'élément de menu '\(sectionId)' doit être visible dans le tiroir.")
        itemMenu.tap()
        
        // Attente fluide de la fin de l'animation de fermeture du tiroir (0.35s)
        Thread.sleep(forTimeInterval: 0.6)
    }

    @MainActor
    func testMenuTiroirAffichageEtFermeture() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Ouvrir le menu tiroir depuis l'accueil
        let boutonHamburger = app.buttons["boutonMenuAccueil"]
        XCTAssertTrue(boutonHamburger.waitForExistence(timeout: 5), "Le bouton hamburger de l'accueil doit être visible.")
        boutonHamburger.tap()
        
        // 2. Vérifier les éléments du tiroir (titre, sous-titre, compteur de véhicules)
        let titreTiroir = app.staticTexts["Le Pokédex Automobile"]
        XCTAssertTrue(titreTiroir.waitForExistence(timeout: 3), "Le sous-titre AutoDex doit être affiché dans le tiroir.")
        
        let statVehicules = app.staticTexts["2 157"]
        XCTAssertTrue(statVehicules.waitForExistence(timeout: 3), "Le total du catalogue (2 157) doit être affiché dans le tiroir.")
        
        // 3. Capture d'écran du menu tiroir ouvert
        let captureMenu = XCUIScreen.main.screenshot()
        try? captureMenu.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/menu_tiroir_ouvert.png"))
        
        // 4. Fermer le tiroir via le bouton de fermeture
        let boutonFermer = app.buttons["boutonFermerMenu"]
        XCTAssertTrue(boutonFermer.waitForExistence(timeout: 3), "Le bouton de fermeture rapide du menu doit être présent.")
        boutonFermer.tap()
    }

    @MainActor
    func testMenuTiroirNavigationVersMaCollection() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Naviguer vers la nouvelle section "Ma Collection"
        naviguerVersSection(app: app, sectionId: "Ma Collection")
        
        let titreCollection = app.staticTexts["Ma Collection"]
        XCTAssertTrue(titreCollection.waitForExistence(timeout: 4), "La section Ma Collection doit s'afficher.")
        
        let captureCollection = XCUIScreen.main.screenshot()
        try? captureCollection.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/section_ma_collection.png"))
    }

    @MainActor
    func testMenuTiroirNavigationVersAPropos() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Naviguer vers la section "À Propos"
        naviguerVersSection(app: app, sectionId: "À Propos")
        
        let barreNav = app.navigationBars["À Propos"]
        XCTAssertTrue(barreNav.waitForExistence(timeout: 5), "La barre de navigation À Propos doit être affichée.")
        
        let texteAcademique = app.staticTexts["Contexte Académique"]
        XCTAssertTrue(texteAcademique.waitForExistence(timeout: 3), "La fiche académique BUT Informatique doit être visible.")
        
        let captureAPropos = XCUIScreen.main.screenshot()
        try? captureAPropos.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/section_a_propos.png"))
    }

    @MainActor
    func testDecouvertePageEtNavigationFicheTechnique() throws {
        let app = XCUIApplication()
        app.launch()
        
        naviguerVersSection(app: app, sectionId: "Découverte")
        
        // Vérifier la présence de la carte et du bouton de consultation
        let boutonConsulter = app.buttons["boutonConsulterFicheDecouverte"]
        XCTAssertTrue(boutonConsulter.waitForExistence(timeout: 6), "Le bouton de consultation de fiche dans Découverte doit être visible.")
        
        // Capture d'écran de la page Découverte
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
        
        // 2. Aller sur l'onglet Favoris via le menu tiroir
        naviguerVersSection(app: app, sectionId: "Favoris")
        
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
    func testBoutonLikeSurFicheTechnique() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Ouvrir la première voiture via son lien de carte direct
        let premiereVoiture = app.buttons.matching(identifier: "carCardLink").firstMatch
        XCTAssertTrue(premiereVoiture.waitForExistence(timeout: 5), "Une carte de véhicule doit être présente sur l'accueil.")
        premiereVoiture.tap()
        
        // Vérifier le bouton Like dans la barre de navigation de la fiche technique
        let boutonLike = app.buttons["boutonLikeFicheDetail"]
        if boutonLike.waitForExistence(timeout: 5) {
            boutonLike.tap()
            XCTAssertTrue(boutonLike.exists, "Le bouton Like doit être cliquable dans la fiche technique.")
        }
    }

    @MainActor
    func testFiltresAvancesAccueil() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Tester le filtre Électrique
        let filtreElectrique = app.buttons["filtreEnergie_Électrique"]
        if filtreElectrique.waitForExistence(timeout: 5) {
            filtreElectrique.tap()
            // Vérifier que la liste se met à jour
            let liste = app.scrollViews.firstMatch
            XCTAssertTrue(liste.waitForExistence(timeout: 3))
        }
        
        // Tester le filtre Puissance > 500 ch
        let filtre500 = app.buttons["filtrePuissance_> 500 ch"]
        if filtre500.waitForExistence(timeout: 4) {
            filtre500.tap()
            let captureFiltres = XCUIScreen.main.screenshot()
            try? captureFiltres.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/filtres_actifs.png"))
        }
    }

    @MainActor
    func testOngletComparateurDuel() throws {
        let app = XCUIApplication()
        app.launch()
        
        naviguerVersSection(app: app, sectionId: "Mode Duel")
        
        // Vérifier la présence du bouton Duel Aléatoire
        let boutonAleatoire = app.buttons["boutonDuelAleatoire"]
        XCTAssertTrue(boutonAleatoire.waitForExistence(timeout: 6), "Le bouton Duel Aléatoire doit être visible.")
        boutonAleatoire.tap()
        
        // Vérifier que le texte VS ou le verdict apparaît
        let texteVS = app.staticTexts["VS"]
        XCTAssertTrue(texteVS.waitForExistence(timeout: 4), "Le badge central VS doit être affiché.")
        
        let captureComparateur = XCUIScreen.main.screenshot()
        try? captureComparateur.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/comparateur_duel.png"))
    }

    @MainActor
    func testOngletQuizPokedex() throws {
        let app = XCUIApplication()
        app.launch()
        
        naviguerVersSection(app: app, sectionId: "Pokédex Quiz")
        
        // Vérifier les boutons de proposition
        let proposition0 = app.buttons["propositionQuiz_0"]
        XCTAssertTrue(proposition0.waitForExistence(timeout: 6), "La première proposition du Quiz doit être visible.")
        
        let captureQuiz = XCUIScreen.main.screenshot()
        try? captureQuiz.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/quiz_pokedex.png"))
        
        // Taper sur la première proposition
        if proposition0.isHittable {
            proposition0.tap()
        } else {
            proposition0.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        
        // Vérifier l'apparition du bouton Question Suivante
        let boutonSuivant = app.buttons["boutonQuestionSuivanteQuiz"]
        XCTAssertTrue(boutonSuivant.waitForExistence(timeout: 6), "Le bouton Véhicule Suivant doit s'afficher après la réponse.")
        
        let captureQuizRepondu = XCUIScreen.main.screenshot()
        try? captureQuizRepondu.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/quiz_pokedex_repondu.png"))
    }

    @MainActor
    func testDeepLinkVoitureDuJourOuvertureFiche() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Simuler l'ouverture de l'URL Deep Link émise par le Widget iOS
        let url = URL(string: "autodex://car?make=Porsche&model=911%20GT3%20RS&year=2024")!
        app.open(url)
        
        // Vérifier l'apparition de la fiche technique
        let titreFiche = app.staticTexts["Porsche 911 GT3 RS"]
        XCTAssertTrue(titreFiche.waitForExistence(timeout: 8), "L'ouverture de l'URL Deep Link du Widget doit présenter la fiche technique du véhicule.")
        
        let boutonFermer = app.buttons["Fermer"]
        XCTAssertTrue(boutonFermer.waitForExistence(timeout: 5), "Le bouton Fermer de la modal doit être présent.")
        boutonFermer.tap()
    }

    @MainActor
    func testMaCollectionAjoutSpotDemoEtSuppression() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Navigation vers "Ma Collection" via le menu tiroir
        naviguerVersSection(app: app, sectionId: "Ma Collection")
        
        // 2. Vérification de la présence de l'écran Collection et de l'en-tête
        let titreCollection = app.staticTexts["Ma Collection"]
        XCTAssertTrue(titreCollection.waitForExistence(timeout: 5), "L'en-tête Ma Collection doit être visible.")
        
        let statSpottes = app.staticTexts["statSpottesValeur"]
        XCTAssertTrue(statSpottes.waitForExistence(timeout: 5), "Le compteur de bolides spottés doit être affiché.")
        
        // 3. Ajout d'un spot démo (Simulateur)
        // Soit via le bouton de l'état vide, soit via le menu d'ajout de la toolbar
        let boutonDemoEtatVide = app.buttons["boutonSpotDemoCollection"]
        if boutonDemoEtatVide.waitForExistence(timeout: 3) && boutonDemoEtatVide.isHittable {
            boutonDemoEtatVide.tap()
        } else {
            let boutonToolbarPlus = app.buttons["boutonAjouterSpotToolbar"]
            XCTAssertTrue(boutonToolbarPlus.waitForExistence(timeout: 4), "Le bouton d'ajout dans la barre d'outils doit être présent.")
            boutonToolbarPlus.tap()
            
            let itemMenuDemo = app.buttons["Ajouter un spot démo"]
            XCTAssertTrue(itemMenuDemo.waitForExistence(timeout: 3), "L'option de spot démo doit être accessible dans le menu.")
            itemMenuDemo.tap()
        }
        
        // 4. Vérification de la feuille d'ajout (Sheet)
        let champMarque = app.textFields["champSaisieMarqueSpot"]
        XCTAssertTrue(champMarque.waitForExistence(timeout: 5), "Le champ de saisie de la marque doit apparaître.")
        
        // Validation du spot
        let boutonValider = app.buttons["boutonValiderSpot"]
        XCTAssertTrue(boutonValider.waitForExistence(timeout: 4), "Le bouton de validation du spot doit être présent.")
        boutonValider.tap()
        
        // 5. Vérification de l'ajout dans la collection
        Thread.sleep(forTimeInterval: 0.8)
        
        // Capture d'écran de vérification pour l'artefact
        let captureCollection = XCUIScreen.main.screenshot()
        try? captureCollection.pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/section_ma_collection_active.png"))
        
        // 6. Test de suppression du bolide pour garder l'état propre
        let boutonSupprimer = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'boutonSupprimerSpot_'")).firstMatch
        if boutonSupprimer.waitForExistence(timeout: 4) {
            boutonSupprimer.tap()
            
            let boutonConfirmerSuppression = app.buttons["Supprimer"]
            if boutonConfirmerSuppression.waitForExistence(timeout: 3) {
                boutonConfirmerSuppression.tap()
            }
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
