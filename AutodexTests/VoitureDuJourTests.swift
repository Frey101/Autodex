//
//  VoitureDuJourTests.swift
//  AutodexTests
//
//  Created by Tom Tas on 20/11/2026.
//

import XCTest
@testable import Autodex

final class VoitureDuJourTests: XCTestCase {

    var service: VoitureDuJourService!

    override func setUp() {
        super.setUp()
        service = VoitureDuJourService.shared
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - 1. Tests d'Intégrité du Catalogue Émblematique
    func testCatalogueEmblematiqueContientAuMoins31Vehicules() {
        XCTAssertGreaterThanOrEqual(
            service.catalogueEmblematique.count,
            31,
            "Le catalogue doit contenir au moins 31 véhicules pour couvrir tous les jours d'un mois."
        )
    }

    func testChaqueVehiculePossedeChampsObligatoiresValides() {
        for voiture in service.catalogueEmblematique {
            XCTAssertFalse(voiture.make.isEmpty, "La marque ne doit pas être vide.")
            XCTAssertFalse(voiture.model.isEmpty, "Le modèle ne doit pas être vide.")
            XCTAssertGreaterThan(voiture.year, 1900, "L'année doit être réaliste (> 1900).")
            XCTAssertNotNil(voiture.horsepower, "La puissance doit être renseignée pour les bolides emblématiques.")
            XCTAssertGreaterThan(voiture.horsepower ?? 0, 100, "Chaque bolide emblématique doit faire plus de 100 ch.")
            XCTAssertFalse(voiture.anecdote.isEmpty, "Une anecdote historique ou technique doit être fournie.")
        }
    }

    // MARK: - 2. Tests de l'Algorithme Déterministe
    func testMemeDateRenvoieToujoursLeMemeVehicule() {
        let calendar = Calendar.current
        var composants = DateComponents()
        composants.year = 2026
        composants.month = 11
        composants.day = 20
        composants.hour = 14
        composants.minute = 30
        let dateTest = calendar.date(from: composants)!

        let tirage1 = service.obtenirVoitureDuJour(pour: dateTest)
        let tirage2 = service.obtenirVoitureDuJour(pour: dateTest)

        XCTAssertEqual(tirage1.make, tirage2.make, "Deux appels à la même date doivent renvoyer la même marque.")
        XCTAssertEqual(tirage1.model, tirage2.model, "Deux appels à la même date doivent renvoyer le même modèle.")
        XCTAssertEqual(tirage1.year, tirage2.year, "Deux appels à la même date doivent renvoyer la même année.")
        XCTAssertEqual(tirage1.dateJour, "2026-11-20")
    }

    func testHeureDifferenteDansLaMemeJourneeGardeLeMemeVehicule() {
        let calendar = Calendar.current
        var matinee = DateComponents()
        matinee.year = 2026
        matinee.month = 11
        matinee.day = 20
        matinee.hour = 10
        let dateMatin = calendar.date(from: matinee)!

        var soiree = DateComponents()
        soiree.year = 2026
        soiree.month = 11
        soiree.day = 20
        soiree.hour = 14
        let dateSoir = calendar.date(from: soiree)!

        let voitureMatin = service.obtenirVoitureDuJour(pour: dateMatin)
        let voitureSoir = service.obtenirVoitureDuJour(pour: dateSoir)

        XCTAssertEqual(voitureMatin.id, voitureSoir.id, "Matin et soir du même jour doivent produire le même véhicule.")
    }

    func testJourSuivantProduitUnVehiculeDifferent() {
        let calendar = Calendar.current
        var jourJ = DateComponents()
        jourJ.year = 2026
        jourJ.month = 11
        jourJ.day = 20
        let dateJ = calendar.date(from: jourJ)!

        var jourJPlus1 = DateComponents()
        jourJPlus1.year = 2026
        jourJPlus1.month = 11
        jourJPlus1.day = 21
        let dateJPlus1 = calendar.date(from: jourJPlus1)!

        let voiture1 = service.obtenirVoitureDuJour(pour: dateJ)
        let voiture2 = service.obtenirVoitureDuJour(pour: dateJPlus1)

        XCTAssertNotEqual(
            voiture1.id,
            voiture2.id,
            "Le lendemain à 00:00, la voiture du jour doit être renouvelée."
        )
    }

    func testIndexPourDateNeDepassePasLaTailleDuCatalogue() {
        let maxIndex = service.catalogueEmblematique.count - 1
        let calendar = Calendar.current

        for jourOffset in 0..<365 {
            let date = calendar.date(byAdding: .day, value: jourOffset, to: Date())!
            let index = service.indexPourDate(date)
            XCTAssertGreaterThanOrEqual(index, 0)
            XCTAssertLessThanOrEqual(index, maxIndex)
        }
    }

    // MARK: - 3. Tests de Prochaine Date de Rafraîchissement
    func testProchaineDateRafraichissementEstMinuitLeLendemain() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 11
        dateComponents.day = 20
        dateComponents.hour = 15
        let dateInitiale = calendar.date(from: dateComponents)!

        let prochaineDate = service.prochaineDateRafraichissement(depuis: dateInitiale)
        let composantsProchaine = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: prochaineDate)

        XCTAssertEqual(composantsProchaine.day, 21, "Le rafraîchissement doit être prévu le jour 21.")
        XCTAssertEqual(composantsProchaine.hour, 0, "Le rafraîchissement doit être prévu à minuit (00h).")
        XCTAssertEqual(composantsProchaine.minute, 0, "Le rafraîchissement doit être prévu à 00m.")
    }

    // MARK: - 4. Tests Deep Link URL Scheme (autodex://car)
    func testDeepLinkUrlFormat() {
        let voiture = service.catalogueEmblematique[0]
        let url = voiture.deepLinkURL

        XCTAssertEqual(url.scheme, "autodex")
        XCTAssertEqual(url.host, "car")
        XCTAssertTrue(url.absoluteString.contains("make=\(voiture.make)"))
        XCTAssertTrue(url.absoluteString.contains("year=\(voiture.year)"))
    }

    func testAnalyserUrlDeepLinkValide() {
        let url = URL(string: "autodex://car?make=Porsche&model=911%20GT3%20RS&year=2024")!
        let resultat = service.analyserUrlDeepLink(url)

        XCTAssertNotNil(resultat)
        XCTAssertEqual(resultat?.make, "Porsche")
        XCTAssertEqual(resultat?.model, "911 GT3 RS")
        XCTAssertEqual(resultat?.year, 2024)
    }

    func testAnalyserUrlDeepLinkSansAnneeEstValide() {
        let url = URL(string: "autodex://car?make=Ferrari&model=F40")!
        let resultat = service.analyserUrlDeepLink(url)

        XCTAssertNotNil(resultat)
        XCTAssertEqual(resultat?.make, "Ferrari")
        XCTAssertEqual(resultat?.model, "F40")
        XCTAssertNil(resultat?.year)
    }

    func testAnalyserUrlDeepLinkInvalideRejette() {
        // Schéma erroné
        let urlHttp = URL(string: "https://autodex.app/car?make=Porsche&model=911")!
        XCTAssertNil(service.analyserUrlDeepLink(urlHttp))

        // Hôte erroné
        let urlHote = URL(string: "autodex://settings?make=Porsche")!
        XCTAssertNil(service.analyserUrlDeepLink(urlHote))

        // Paramètre make manquant
        let urlSansMake = URL(string: "autodex://car?model=911")!
        XCTAssertNil(service.analyserUrlDeepLink(urlSansMake))
    }

    // MARK: - 5. Tests de Conversion vers Car et Affichage
    func testConversionVersModeleCar() {
        let data = service.catalogueEmblematique[1] // Ferrari F40
        let car = data.toCar()

        XCTAssertEqual(car.Make_Name, "Ferrari")
        XCTAssertEqual(car.Model_Name, "F40")
        XCTAssertEqual(car.year, 1987)
        XCTAssertEqual(car.horsepower, 478)
        XCTAssertEqual(car.displayName, "Ferrari F40")
    }

    func testFormatSousTitreAffichage() {
        let data = service.catalogueEmblematique[0] // Porsche 911 GT3 RS
        let sousTitre = data.displaySubtitle

        XCTAssertTrue(sousTitre.contains("Modèle 2024"))
        XCTAssertTrue(sousTitre.contains("525 ch"))
        XCTAssertTrue(sousTitre.contains("Essence"))
    }

    // MARK: - 6. Tests Synchronisation App Group
    func testSauvegardeEtLectureSynchronisee() {
        let voiture = service.synchroniser()
        let chargee = service.chargerDepuisAppGroup()

        XCTAssertNotNil(chargee, "La voiture synchronisée doit pouvoir être relue.")
        XCTAssertEqual(voiture.make, chargee?.make)
        XCTAssertEqual(voiture.model, chargee?.model)
    }
}
