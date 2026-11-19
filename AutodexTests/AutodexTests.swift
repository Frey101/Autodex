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

    // Test 8 : Pagination par tranches de 20 éléments
    @MainActor
    func testPaginationVingtElements() async {
        let viewModel = CarViewModel()
        await viewModel.fetchTrendingCars()
        
        XCTAssertEqual(viewModel.taillePage, 20, "La taille de page doit être de 20.")
        XCTAssertEqual(viewModel.limitePagination, 20, "La limite initiale doit être de 20.")
        XCTAssertLessThanOrEqual(viewModel.carsAffichees.count, 20, "Le nombre d'éléments affichés ne doit pas dépasser 20 initialement.")
        
        if viewModel.peutChargerPlus {
            viewModel.chargerPageSuivante()
            XCTAssertEqual(viewModel.limitePagination, 40, "Après chargement de page, la limite doit être de 40.")
            XCTAssertLessThanOrEqual(viewModel.carsAffichees.count, 40)
        }
    }

    // Test 8b : Incrémentations successives de pagination et réinitialisation
    @MainActor
    func testPaginationIncrementationConsecutiveEtReinitialisation() async {
        let viewModel = CarViewModel()
        await viewModel.fetchTrendingCars()
        
        XCTAssertEqual(viewModel.limitePagination, 20)
        
        viewModel.chargerPageSuivante()
        XCTAssertEqual(viewModel.limitePagination, 40)
        
        viewModel.chargerPageSuivante()
        XCTAssertEqual(viewModel.limitePagination, 60)
        
        viewModel.reinitialiserPagination()
        XCTAssertEqual(viewModel.limitePagination, 20, "La réinitialisation doit restaurer la taille de page initiale de 20.")
    }

    // Test 8c : Réinitialisation automatique de la pagination lors d'une recherche ou changement d'onglet
    @MainActor
    func testPaginationReinitialiseeSurRechercheEtOnglets() async {
        let viewModel = CarViewModel()
        await viewModel.fetchTrendingCars()
        
        // Simule plusieurs scrolls
        viewModel.chargerPageSuivante()
        viewModel.chargerPageSuivante()
        XCTAssertEqual(viewModel.limitePagination, 60)
        
        // Lancer une recherche avec beaucoup de résultats (> 20, ex: BMW avec 91 modèles)
        await viewModel.fetchCars(searchQuery: "BMW")
        XCTAssertEqual(viewModel.limitePagination, 20, "Une nouvelle recherche doit remettre la pagination à 20.")
        XCTAssertEqual(viewModel.carsAffichees.count, 20, "Exactement 20 éléments doivent être affichés initialement.")
        XCTAssertTrue(viewModel.peutChargerPlus, "BMW ayant 91 résultats, peutChargerPlus doit être vrai.")
        
        // Simuler un scroll sur la recherche BMW
        viewModel.chargerPageSuivante()
        XCTAssertEqual(viewModel.limitePagination, 40)
        XCTAssertEqual(viewModel.carsAffichees.count, 40)
        
        // Basculer sur les nouveautés doit réinitialiser la pagination à 20
        await viewModel.fetchNewReleases()
        XCTAssertEqual(viewModel.limitePagination, 20, "Le basculement sur Nouveautés doit remettre la pagination à 20.")
        XCTAssertLessThanOrEqual(viewModel.carsAffichees.count, 20)
    }

    // Test 8d : Comportement de la pagination avec un résultat inférieur à 20 (ex: Porsche avec 6 modèles)
    @MainActor
    func testPaginationResultatsInferieursAVingt() async {
        let viewModel = CarViewModel()
        await viewModel.fetchCars(searchQuery: "Porsche")
        
        let nombreVoitures = viewModel.cars.count
        XCTAssertTrue(nombreVoitures > 0 && nombreVoitures < 20, "Le catalogue contient moins de 20 Porsche.")
        XCTAssertEqual(viewModel.carsAffichees.count, nombreVoitures, "Toutes les voitures doivent être affichées.")
        XCTAssertFalse(viewModel.peutChargerPlus, "Il ne doit pas être possible de charger plus d'éléments.")
        
        // Tenter de charger la page suivante ne doit pas modifier la pagination
        viewModel.chargerPageSuivante()
        XCTAssertEqual(viewModel.limitePagination, 20)
        XCTAssertEqual(viewModel.carsAffichees.count, nombreVoitures)
    }

    // Test 9 : Chargement des nouveautés récentes (sorties des 6 derniers mois / >= 2025)
    @MainActor
    func testChargementNouveautesRecentes() async {
        let viewModel = CarViewModel()
        await viewModel.fetchNewReleases()
        
        XCTAssertFalse(viewModel.cars.isEmpty, "La liste des nouveautés ne doit pas être vide.")
        let toutesRecentes = viewModel.cars.allSatisfy { ($0.year ?? 0) >= 2025 }
        XCTAssertTrue(toutesRecentes, "Toutes les nouveautés doivent être sorties ces 6 derniers mois (>= 2025).")
        XCTAssertGreaterThanOrEqual(viewModel.cars.count, 40, "La liste des nouveautés doit contenir au moins 40 modèles récents.")
    }

    // Test 10 : Pagination sur l'onglet Nouveautés
    @MainActor
    func testPaginationSurOngletNouveautes() async {
        let viewModel = CarViewModel()
        await viewModel.fetchNewReleases()
        
        XCTAssertEqual(viewModel.limitePagination, 20)
        XCTAssertEqual(viewModel.carsAffichees.count, 20)
        XCTAssertTrue(viewModel.peutChargerPlus, "Nouveautés doit contenir plus de 20 modèles pour permettre la pagination.")
        
        viewModel.chargerPageSuivante()
        XCTAssertEqual(viewModel.limitePagination, 40)
        XCTAssertEqual(viewModel.carsAffichees.count, 40)
    }

    // Test 11 : Résolution d'un Favori vers sa fiche Car complète avec spécifications
    @MainActor
    func testResolutionFavoriVersCarComplet() {
        let viewModel = CarViewModel()
        let favori = FavoriteCar(make: "Ferrari", model: "F80", year: 2025)
        let carTrouvee = viewModel.trouverVehicule(pour: favori)
        
        XCTAssertEqual(carTrouvee.Make_Name?.lowercased(), "ferrari")
        XCTAssertTrue(carTrouvee.displayName.contains("Ferrari"))
        XCTAssertEqual(carTrouvee.horsepower, 1200, "Le modèle Ferrari F80 doit avoir sa puissance de 1200 ch renseignée.")
        
        // Test de repli pour un favori inexistant dans le catalogue local
        let favoriInconnu = FavoriteCar(make: "MarqueInconnue", model: "PrototypeX", year: 2030)
        let carRepli = viewModel.trouverVehicule(pour: favoriInconnu)
        XCTAssertEqual(carRepli.Make_Name, "MarqueInconnue")
        XCTAssertEqual(carRepli.Model_Name, "PrototypeX")
        XCTAssertEqual(carRepli.year, 2030)
    }

    // Test 12 : Vérification du filtrage de variantes complexes pour Wikipédia
    func testWikipediaServiceNettoyageVariantes() async {
        let service = WikipediaService.shared
        // Requête sur modèle avec parenthèses
        let detail = await service.chargerInfosVehicule(marque: "Peugeot", modele: "508 PSE (Peugeot Sport Engineered)")
        // Même si la requête réseau peut être mockée ou dépendre de l'environnement, on vérifie que l'acteur répond sans crash
        if let detail = detail {
            XCTAssertFalse(detail.titre.isEmpty)
            if let photo = detail.photoUrl {
                XCTAssertFalse(photo.hasSuffix(".svg"), "Les images vectorielles SVG de logos doivent être rejetées.")
                XCTAssertFalse(photo.lowercased().contains("logo"), "Les URLs contenant 'logo' doivent être exclues.")
            }
        }
    }
}
