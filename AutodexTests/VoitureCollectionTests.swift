//
//  VoitureCollectionTests.swift
//  AutodexTests
//
//  Created by Tom Tas on 20/11/2026.
//

import XCTest
import SwiftData
import UIKit
@testable import Autodex

final class VoitureCollectionTests: XCTestCase {

    var photoService: CollectionPhotoService!

    override func setUp() {
        super.setUp()
        photoService = CollectionPhotoService.shared
    }

    override func tearDown() {
        photoService = nil
        super.tearDown()
    }

    // MARK: - 1. Tests du Modèle VoitureCollection
    func testCreationVoitureCollection() {
        let voiture = VoitureCollection(make: "Porsche", model: "911 Carrera", photoFileName: "spot_test.jpg")

        XCTAssertEqual(voiture.make, "Porsche")
        XCTAssertEqual(voiture.model, "911 Carrera")
        XCTAssertEqual(voiture.photoFileName, "spot_test.jpg")
        XCTAssertFalse(voiture.id.uuidString.isEmpty)
        XCTAssertEqual(voiture.displayName, "Porsche 911 Carrera")
    }

    func testNettoyageEspacesBlancs() {
        let voiture = VoitureCollection(make: "  Ferrari  ", model: "  F40  ", photoFileName: "f40.jpg")

        XCTAssertEqual(voiture.make, "Ferrari")
        XCTAssertEqual(voiture.model, "F40")
        XCTAssertEqual(voiture.displayName, "Ferrari F40")
    }

    func testDateAfficheeFormatteCorrectement() {
        let dateTest = Date()
        let voiture = VoitureCollection(make: "Alpine", model: "A110", photoFileName: "a110.jpg", dateSpotting: dateTest)

        XCTAssertFalse(voiture.dateAffichee.isEmpty)
    }

    // MARK: - 2. Tests du Service Photo sur Disque Local
    func testSauvegardeEtLecturePhotoSurDisque() {
        let imageOriginale = photoService.genererImageDemo(marque: "Bugatti", modele: "Chiron")

        guard let nomFichier = photoService.sauvegarderPhoto(imageOriginale) else {
            XCTFail("La sauvegarde sur disque doit réussir.")
            return
        }

        XCTAssertTrue(nomFichier.hasPrefix("spot_"))
        XCTAssertTrue(nomFichier.hasSuffix(".jpg"))

        // Rechargement depuis le disque
        let imageChargee = photoService.chargerPhoto(nomFichier: nomFichier)
        XCTAssertNotNil(imageChargee, "L'image sauvegardée sur le disque doit pouvoir être relue.")

        // Nettoyage
        photoService.supprimerPhoto(nomFichier: nomFichier)
    }

    func testSuppressionPhotoDuDisque() {
        let image = photoService.genererImageDemo(marque: "Ferrari", modele: "Roma")
        guard let nomFichier = photoService.sauvegarderPhoto(image) else {
            XCTFail("La sauvegarde initiale doit réussir.")
            return
        }

        // Vérifier qu'elle existe
        XCTAssertNotNil(photoService.chargerPhoto(nomFichier: nomFichier))

        // Supprimer
        photoService.supprimerPhoto(nomFichier: nomFichier)

        // Vérifier qu'elle est supprimée
        XCTAssertNil(photoService.chargerPhoto(nomFichier: nomFichier))
    }

    func testChargementFichierInexistantRenvoieNil() {
        let inexistant = photoService.chargerPhoto(nomFichier: "fichier_qui_n_existe_absolument_pas_12345.jpg")
        XCTAssertNil(inexistant, "Charger un nom de fichier inexistant doit renvoyer nil sans crash.")
    }

    func testGenerateurImageDemoValide() {
        let imageDemo = photoService.genererImageDemo(marque: "Renault", modele: "5 Turbo")
        XCTAssertGreaterThan(imageDemo.size.width, 0)
        XCTAssertGreaterThan(imageDemo.size.height, 0)
    }

    // MARK: - 3. Tests de Persistance SwiftData
    @MainActor
    func testPersistanceSwiftDataVoitureCollection() throws {
        let schema = Schema([VoitureCollection.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let voiture = VoitureCollection(make: "McLaren", model: "720S", photoFileName: "mclaren_720s.jpg")
        context.insert(voiture)
        try context.save()

        let descriptor = FetchDescriptor<VoitureCollection>()
        let resultats = try context.fetch(descriptor)

        XCTAssertEqual(resultats.count, 1)
        XCTAssertEqual(resultats.first?.make, "McLaren")
        XCTAssertEqual(resultats.first?.model, "720S")
    }

    @MainActor
    func testCalculStatistiquesMarquesUniques() throws {
        let schema = Schema([VoitureCollection.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        // 3 véhicules avec 2 marques distinctes
        context.insert(VoitureCollection(make: "Porsche", model: "911 GT3", photoFileName: "p1.jpg"))
        context.insert(VoitureCollection(make: "Porsche", model: "Taycan", photoFileName: "p2.jpg"))
        context.insert(VoitureCollection(make: "Audi", model: "RS6", photoFileName: "a1.jpg"))
        try context.save()

        let descriptor = FetchDescriptor<VoitureCollection>()
        let collections = try context.fetch(descriptor)

        let nombreTotal = collections.count
        let marquesUniques = Set(collections.map { $0.make.lowercased() }).count

        XCTAssertEqual(nombreTotal, 3, "Le total de bolides doit être 3.")
        XCTAssertEqual(marquesUniques, 2, "Il doit y avoir 2 marques uniques (Porsche, Audi).")
    }

    @MainActor
    func testSuppressionVoitureDansSwiftData() throws {
        let schema = Schema([VoitureCollection.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let voiture = VoitureCollection(make: "Lamborghini", model: "Diablo", photoFileName: "diablo.jpg")
        context.insert(voiture)
        try context.save()

        var resultats = try context.fetch(FetchDescriptor<VoitureCollection>())
        XCTAssertEqual(resultats.count, 1)

        // Suppression
        context.delete(voiture)
        try context.save()

        resultats = try context.fetch(FetchDescriptor<VoitureCollection>())
        XCTAssertEqual(resultats.count, 0, "La collection doit être vide après suppression.")
    }

    @MainActor
    func testTriChronologiqueInverseParDefaut() throws {
        let schema = Schema([VoitureCollection.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let ancienne = VoitureCollection(make: "Peugeot", model: "205 GTi", photoFileName: "p205.jpg", dateSpotting: Date(timeIntervalSince1970: 1000))
        let recente = VoitureCollection(make: "Ferrari", model: "LaFerrari", photoFileName: "laferrari.jpg", dateSpotting: Date(timeIntervalSince1970: 5000))

        context.insert(ancienne)
        context.insert(recente)
        try context.save()

        var descriptor = FetchDescriptor<VoitureCollection>(sortBy: [SortDescriptor(\.dateSpotting, order: .reverse)])
        let tries = try context.fetch(descriptor)

        XCTAssertEqual(tries.first?.model, "LaFerrari", "Le véhicule le plus récent doit apparaître en premier.")
        XCTAssertEqual(tries.last?.model, "205 GTi", "Le véhicule le plus ancien doit apparaître en dernier.")
    }

    func testMultipleFichiersPhotosUniciteNoms() {
        let img1 = photoService.genererImageDemo(marque: "Audi", modele: "R8")
        let img2 = photoService.genererImageDemo(marque: "BMW", modele: "M5")

        guard let nom1 = photoService.sauvegarderPhoto(img1),
              let nom2 = photoService.sauvegarderPhoto(img2) else {
            XCTFail("Les sauvegardes doivent réussir.")
            return
        }

        XCTAssertNotEqual(nom1, nom2, "Chaque photo doit posséder un nom de fichier UUID unique.")

        // Nettoyage
        photoService.supprimerPhoto(nomFichier: nom1)
        photoService.supprimerPhoto(nomFichier: nom2)
    }

    func testVoitureCollectionAffichageCasLimites() {
        let voitureSansModele = VoitureCollection(make: "Maserati", model: "", photoFileName: "maserati.jpg")
        XCTAssertEqual(voitureSansModele.displayName, "Maserati")

        let voitureSansMarque = VoitureCollection(make: "", model: "Test Car", photoFileName: "test.jpg")
        XCTAssertEqual(voitureSansMarque.displayName, "Test Car")
    }
}
