//
//  AutodexTests.swift
//  AutodexTests
//
//  Created by Alyssia Frey on 29/05/2026.
//

import XCTest
@testable import Autodex

final class AutodexTests: XCTestCase {

    // Test 1 : Vérification de la présence et du décodage du catalogue local
    func testDecodageCatalogueLocal() throws {
        let bundle = Bundle(for: type(of: self))
        let url = Bundle.main.url(forResource: "car_details", withExtension: "json") 
            ?? bundle.url(forResource: "car_details", withExtension: "json")
        
        XCTAssertNotNil(url, "Le fichier car_details.json doit être accessible dans le bundle de l'application.")
        
        if let url = url {
            let data = try Data(contentsOf: url)
            let vehicules = try JSONDecoder().decode([DetailVehiculeData].self, from: data)
            
            XCTAssertGreaterThan(vehicules.count, 2000, "Le catalogue doit contenir plus de 2000 véhicules.")
            
            // Vérification de la présence de marques phares
            let marques = Set(vehicules.map { $0.brand.lowercased() })
            XCTAssertTrue(marques.contains("porsche"), "Le catalogue doit contenir Porsche.")
            XCTAssertTrue(marques.contains("bmw"), "Le catalogue doit contenir BMW.")
            XCTAssertTrue(marques.contains("audi"), "Le catalogue doit contenir Audi.")
        }
    }

    // Test 2 : Vérification du mapping vers le modèle Car et les specs moteur
    func testMappingVersCarAvecPuissance() throws {
        let moteur = MoteurData(name: "4.0L Flat-6", power_hp: 510, fuel: "Petrol", transmissions: ["PDK", "Manual"])
        let detail = DetailVehiculeData(
            id: 9999,
            brand: "Porsche",
            model: "911 GT3",
            production_year_start: 2022,
            production_year_end: 2024,
            body_styles: ["Coupe"],
            fuel_types: ["Petrol"],
            engines: [moteur]
        )
        
        let car = Car(fromDetail: detail)
        
        XCTAssertEqual(car.Make_Name, "Porsche")
        XCTAssertEqual(car.Model_Name, "911 GT3")
        XCTAssertEqual(car.year, 2022)
        XCTAssertEqual(car.horsepower, 510)
        XCTAssertEqual(car.transmission, "PDK")
        XCTAssertEqual(car.engineName, "4.0L Flat-6")
        XCTAssertEqual(car.displayName, "Porsche 911 GT3")
        XCTAssertTrue(car.displaySubtitle.contains("510 ch"), "Le sous-titre doit afficher la puissance en chevaux.")
    }

    // Test 3 : Vérification du ViewModel et de la recherche instantanée
    @MainActor
    func testRechercheCatalogueLocalViewModel() async {
        let viewModel = CarViewModel()
        
        // Si le catalogue est chargé
        if !viewModel.catalogueLocal.isEmpty {
            await viewModel.fetchCars(searchQuery: "Carrera")
            XCTAssertFalse(viewModel.cars.isEmpty, "La recherche 'Carrera' doit retourner des modèles.")
            
            let premierVehicule = viewModel.cars.first
            XCTAssertEqual(premierVehicule?.Make_Name?.lowercased(), "porsche")
            XCTAssertNotNil(premierVehicule?.horsepower, "Les specs moteur doivent être renseignées.")
        }
    }

    // Test 4 : Vérification de la sélection des véhicules populaires
    @MainActor
    func testChargementVehiculesPopulaires() async {
        let viewModel = CarViewModel()
        await viewModel.fetchTrendingCars()
        
        XCTAssertFalse(viewModel.cars.isEmpty, "La sélection populaire ne doit pas être vide.")
        XCTAssertFalse(viewModel.isLoading, "Le chargement doit être terminé après fetch.")
    }

    // Test 4 bis : Vérification de la recherche dynamique et restauration lors de l'effacement
    @MainActor
    func testRechercheDynamiqueEffacementRestaurePopulaires() async {
        let viewModel = CarViewModel()
        
        // 1. Recherche d'un mot-clé
        await viewModel.fetchCars(searchQuery: "Civic")
        XCTAssertFalse(viewModel.cars.isEmpty, "La recherche Civic doit renvoyer des résultats.")
        let tousCivic = viewModel.cars.allSatisfy { ($0.Model_Name ?? "").localizedCaseInsensitiveContains("Civic") }
        XCTAssertTrue(tousCivic, "Tous les résultats doivent correspondre à Civic.")
        
        // 2. Effacement complet de la saisie (chaîne vide)
        await viewModel.fetchCars(searchQuery: "")
        XCTAssertFalse(viewModel.cars.isEmpty, "La réinitialisation doit restaurer les véhicules populaires.")
        XCTAssertFalse(viewModel.isLoading, "Le chargement doit être inactif après réinitialisation.")
    }

    // Test 5 : Décodage d'un résumé de réponse Wikipédia REST
    func testDecodageReponseWikipediaSummary() throws {
        let jsonMock = """
        {
            "title": "Porsche 911",
            "extract": "La Porsche 911 est une voiture de sport haut de gamme fabriquée par le constructeur allemand Porsche.",
            "description": "Modèle d'automobile sportive",
            "thumbnail": {
                "source": "https://upload.wikimedia.org/thumb/porsche_thumb.jpg",
                "width": 320,
                "height": 240
            },
            "originalimage": {
                "source": "https://upload.wikimedia.org/porsche_original.jpg",
                "width": 1920,
                "height": 1080
            },
            "content_urls": {
                "mobile": {
                    "page": "https://fr.m.wikipedia.org/wiki/Porsche_911"
                },
                "desktop": {
                    "page": "https://fr.wikipedia.org/wiki/Porsche_911"
                }
            }
        }
        """.data(using: .utf8)!
        
        let summary = try JSONDecoder().decode(WikipediaSummaryResponse.self, from: jsonMock)
        
        XCTAssertEqual(summary.title, "Porsche 911")
        XCTAssertEqual(summary.thumbnail?.source, "https://upload.wikimedia.org/thumb/porsche_thumb.jpg")
        XCTAssertEqual(summary.originalimage?.source, "https://upload.wikimedia.org/porsche_original.jpg")
        XCTAssertEqual(summary.content_urls?.desktop?.page, "https://fr.wikipedia.org/wiki/Porsche_911")
        XCTAssertTrue(summary.extract?.contains("voiture de sport") == true)
    }

    // Test 6 : Décodage d'une recherche MediaWiki pour retrouver le titre exact
    func testDecodageReponseWikipediaSearch() throws {
        let jsonMock = """
        {
            "query": {
                "search": [
                    { "title": "Peugeot 508 II" },
                    { "title": "Peugeot 508 I" }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let searchResponse = try JSONDecoder().decode(WikipediaSearchResponse.self, from: jsonMock)
        
        let premierTitre = searchResponse.query?.search?.first?.title
        XCTAssertEqual(premierTitre, "Peugeot 508 II")
    }

    // Test 7 : Génération et normalisation des URLs de logos de marques
    func testGenerationUrlLogoMarque() throws {
        let service = BrandLogoService.shared
        
        let urlFord = service.urlLogo(pour: "Ford")
        XCTAssertEqual(urlFord?.lastPathComponent, "ford.png")
        
        let urlAlfa = service.urlLogo(pour: "Alfa Romeo")
        XCTAssertEqual(urlAlfa?.lastPathComponent, "alfa-romeo.png")
        
        let urlAston = service.urlLogo(pour: "Aston Martin")
        XCTAssertEqual(urlAston?.lastPathComponent, "aston-martin.png")
        
        let urlMercedes = service.urlLogo(pour: "Mercedes")
        XCTAssertEqual(urlMercedes?.lastPathComponent, "mercedes-benz.png")
    }
}
