//
//  AutodexTests.swift
//  AutodexTests
//
//  Created by Alyssia Frey on 29/05/2026.
//

import XCTest
import SwiftData
@testable import Autodex

final class AutodexTests: XCTestCase {

    // MARK: - 1. Tests Décodage & Mapping Catalogue
    
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

    // Test 3 : Mapping avec moteur sans puissance explicite
    func testMappingVersCarSansPuissanceExplicite() {
        let detail = DetailVehiculeData(
            id: 8888,
            brand: "Renault",
            model: "Clio",
            production_year_start: 2020,
            production_year_end: nil,
            body_styles: ["Hatchback"],
            fuel_types: ["Petrol"],
            engines: nil
        )
        let car = Car(fromDetail: detail)
        XCTAssertEqual(car.Make_Name, "Renault")
        XCTAssertEqual(car.Model_Name, "Clio")
        XCTAssertNil(car.horsepower)
        XCTAssertTrue(car.displaySubtitle.contains("Modèle 2020"))
    }

    // Test 4 : Initialiseur complet manuel de Car
    func testCarInitialiseurComplet() {
        let car = Car(
            Make_Name: "Alpine",
            Model_Name: "A110 R",
            year: 2024,
            vehicleClass: "Coupé",
            fuelType: "petrol",
            cylinders: 4,
            displacement: 1.8,
            transmission: "a",
            drive: "rwd",
            cityMpg: 28,
            highwayMpg: 35,
            horsepower: 300,
            engineName: "1.8 Turbo"
        )
        XCTAssertEqual(car.Make_Name, "Alpine")
        XCTAssertEqual(car.Model_Name, "A110 R")
        XCTAssertEqual(car.year, 2024)
        XCTAssertEqual(car.horsepower, 300)
        XCTAssertEqual(car.cylinders, 4)
        XCTAssertEqual(car.displacement, 1.8)
        XCTAssertEqual(car.transmission, "a")
    }

    // Test 5 : Décodage JSON standard de Car (NHTSA / API)
    func testDecodageCarDepuisJSONStandard() throws {
        let json = """
        {
            "make": "Ferrari",
            "model": "F40",
            "year": 1987,
            "fuel_type": "petrol",
            "cylinders": 8,
            "displacement": 2.9,
            "transmission": "m",
            "drive": "rwd",
            "city_mpg": 12,
            "highway_mpg": 17,
            "class": "Supercar"
        }
        """.data(using: .utf8)!
        
        let car = try JSONDecoder().decode(Car.self, from: json)
        XCTAssertEqual(car.Make_Name, "Ferrari")
        XCTAssertEqual(car.Model_Name, "F40")
        XCTAssertEqual(car.year, 1987)
        XCTAssertEqual(car.cylinders, 8)
        XCTAssertEqual(car.displacement, 2.9)
    }

    // MARK: - 2. Tests Traduction & Localisation Française (Carburant & Boîte)

    // Test 6 : Traduction Petrol / Gas / Gasoline -> Essence
    func testTraductionCarburantEssence() {
        let c1 = Car(Make_Name: "Porsche", Model_Name: "911", fuelType: "Petrol")
        let c2 = Car(Make_Name: "Ford", Model_Name: "Mustang", fuelType: "gasoline")
        let c3 = Car(Make_Name: "Chevrolet", Model_Name: "Corvette", fuelType: "gas")
        let c4 = Car(Make_Name: "Peugeot", Model_Name: "208", fuelType: "essence")

        XCTAssertEqual(c1.displayFuelType, "Essence")
        XCTAssertEqual(c2.displayFuelType, "Essence")
        XCTAssertEqual(c3.displayFuelType, "Essence")
        XCTAssertEqual(c4.displayFuelType, "Essence")
    }

    // Test 7 : Traduction Diesel
    func testTraductionCarburantDiesel() {
        let c1 = Car(Make_Name: "Audi", Model_Name: "A6 TDI", fuelType: "Diesel")
        let c2 = Car(Make_Name: "BMW", Model_Name: "530d", fuelType: "diesel (select markets)")

        XCTAssertEqual(c1.displayFuelType, "Diesel")
        XCTAssertEqual(c2.displayFuelType, "Diesel")
    }

    // Test 8 : Traduction Électrique
    func testTraductionCarburantElectrique() {
        let c1 = Car(Make_Name: "Tesla", Model_Name: "Model S", fuelType: "Electric")
        let c2 = Car(Make_Name: "Porsche", Model_Name: "Taycan", fuelType: "electricity")
        let c3 = Car(Make_Name: "Alpine", Model_Name: "A290", fuelType: "Électrique")

        XCTAssertEqual(c1.displayFuelType, "Électrique")
        XCTAssertEqual(c2.displayFuelType, "Électrique")
        XCTAssertEqual(c3.displayFuelType, "Électrique")
    }

    // Test 9 : Traduction Hybride
    func testTraductionCarburantHybride() {
        let c1 = Car(Make_Name: "Toyota", Model_Name: "Prius", fuelType: "Hybrid")
        let c2 = Car(Make_Name: "BMW", Model_Name: "330e", fuelType: "Plug-in Hybrid")
        let c3 = Car(Make_Name: "Peugeot", Model_Name: "3008", fuelType: "Hybride rechargeable")

        XCTAssertEqual(c1.displayFuelType, "Hybride")
        XCTAssertEqual(c2.displayFuelType, "Hybride")
        XCTAssertEqual(c3.displayFuelType, "Hybride")
    }

    // Test 10 : Traduction Carburants Alternatifs (Hydrogène, GPL, Flex-Fuel)
    func testTraductionCarburantAlternatifs() {
        let c1 = Car(Make_Name: "Toyota", Model_Name: "Mirai", fuelType: "Hydrogen")
        let c2 = Car(Make_Name: "Dacia", Model_Name: "Sandero ECO-G", fuelType: "LPG")
        let c3 = Car(Make_Name: "Ford", Model_Name: "Puma", fuelType: "Flex-Fuel")

        XCTAssertEqual(c1.displayFuelType, "Hydrogène")
        XCTAssertEqual(c2.displayFuelType, "GPL")
        XCTAssertEqual(c3.displayFuelType, "Flex-Fuel (Éthanol)")
    }

    // Test 11 : Traduction Bi-carburation Petrol/Diesel
    func testTraductionCarburantBiCarburation() {
        let car = Car(Make_Name: "Mercedes", Model_Name: "Vito", fuelType: "Petrol/Diesel")
        XCTAssertEqual(car.displayFuelType, "Essence / Diesel")
    }

    // Test 12 : Gestion Carburant Nil ou Vide
    func testTraductionCarburantNilOuVide() {
        let c1 = Car(Make_Name: "Unknown", Model_Name: "Proto", fuelType: nil)
        let c2 = Car(Make_Name: "Unknown", Model_Name: "Proto2", fuelType: "   ")

        XCTAssertNil(c1.displayFuelType)
        XCTAssertNil(c2.displayFuelType)
    }

    // Test 13 : Traduction Boîte Automatique
    func testTraductionTransmissionAutomatique() {
        let c1 = Car(Make_Name: "BMW", Model_Name: "M3", transmission: "a")
        let c2 = Car(Make_Name: "Porsche", Model_Name: "911", transmission: "PDK")
        let c3 = Car(Make_Name: "Volkswagen", Model_Name: "Golf GTI", transmission: "DSG")
        let c4 = Car(Make_Name: "Audi", Model_Name: "RS3", transmission: "Automatic")

        XCTAssertEqual(c1.displayTransmission, "Automatique")
        XCTAssertEqual(c2.displayTransmission, "Automatique")
        XCTAssertEqual(c3.displayTransmission, "Automatique")
        XCTAssertEqual(c4.displayTransmission, "Automatique")
    }

    // Test 14 : Traduction Boîte Manuelle
    func testTraductionTransmissionManuelle() {
        let c1 = Car(Make_Name: "Honda", Model_Name: "Civic Type R", transmission: "m")
        let c2 = Car(Make_Name: "Mazda", Model_Name: "MX-5", transmission: "manual")
        let c3 = Car(Make_Name: "Renault", Model_Name: "Clio RS", transmission: "manuelle")

        XCTAssertEqual(c1.displayTransmission, "Manuelle")
        XCTAssertEqual(c2.displayTransmission, "Manuelle")
        XCTAssertEqual(c3.displayTransmission, "Manuelle")
    }

    // Test 15 : Transmission Nil ou Inconnue
    func testTraductionTransmissionNil() {
        let car = Car(Make_Name: "Test", Model_Name: "Car", transmission: nil)
        XCTAssertNil(car.displayTransmission)
    }

    // MARK: - 3. Tests Propriétés Calculées Modèle Car

    // Test 16 : DisplayName Nom Complet
    func testCarDisplayNameComplet() {
        let car = Car(Make_Name: "Bugatti", Model_Name: "Chiron")
        XCTAssertEqual(car.displayName, "Bugatti Chiron")
    }

    // Test 17 : DisplayName avec Marque Manquante
    func testCarDisplayNameMarqueManquante() {
        let car = Car(Make_Name: nil, Model_Name: "Concept 2026")
        XCTAssertEqual(car.displayName.trimmingCharacters(in: .whitespaces), "Concept 2026")
    }

    // Test 18 : DisplaySubtitle avec Année et Puissance
    func testCarDisplaySubtitleComplet() {
        let car = Car(Make_Name: "Ferrari", Model_Name: "296 GTB", year: 2023, horsepower: 830)
        XCTAssertEqual(car.displaySubtitle, "Modèle 2023 • 830 ch")
    }

    // Test 19 : DisplaySubtitle sans Puissance mais avec Catégorie
    func testCarDisplaySubtitleSansPuissanceMaisCategorie() {
        let car = Car(Make_Name: "Citroën", Model_Name: "Ami", year: 2021, vehicleClass: "micro-car")
        XCTAssertEqual(car.displaySubtitle, "Modèle 2021 • Micro-Car")
    }

    // Test 20 : DisplaySubtitle sans Aucune Caractéristique
    func testCarDisplaySubtitleVide() {
        let car = Car(Make_Name: nil, Model_Name: nil)
        XCTAssertEqual(car.displaySubtitle, "Véhicule")
    }

    // Test 21 : Unicité de l'identifiant UUID
    func testCarIdentifiantsUniques() {
        let c1 = Car(Make_Name: "Porsche", Model_Name: "911")
        let c2 = Car(Make_Name: "Porsche", Model_Name: "911")
        XCTAssertNotEqual(c1.id, c2.id, "Deux instances distinctes doivent avoir un UUID unique.")
    }

    // Test 22 : Conformité Equatable de Car
    func testCarConformiteEquatable() {
        let car = Car(Make_Name: "BMW", Model_Name: "M5")
        XCTAssertEqual(car, car)
    }

    // MARK: - 4. Tests Intégrité Données Catalogue Local

    // Test 23 : Taille totale du catalogue local
    @MainActor
    func testCatalogueLocalNombreElements() {
        let viewModel = CarViewModel()
        XCTAssertGreaterThanOrEqual(viewModel.catalogueLocal.count, 2150, "Le catalogue doit comporter au moins 2150 véhicules.")
    }

    // Test 24 : Cohérence des années de production
    @MainActor
    func testCatalogueLocalAnneesCoherentes() {
        let viewModel = CarViewModel()
        for car in viewModel.catalogueLocal {
            if let year = car.year {
                XCTAssertGreaterThanOrEqual(year, 1880, "L'année ne peut être antérieure aux débuts de l'automobile en 1880 (\(car.displayName)).")
                XCTAssertLessThanOrEqual(year, 2030, "L'année ne peut dépasser 2030 (\(car.displayName)).")
            }
        }
    }

    // Test 25 : Cohérence des puissances moteurs
    @MainActor
    func testCatalogueLocalPuissancesCoherentes() {
        let viewModel = CarViewModel()
        for car in viewModel.catalogueLocal {
            if let hp = car.horsepower {
                XCTAssertGreaterThanOrEqual(hp, 0, "La puissance doit être positive ou nulle (\(car.displayName)).")
                XCTAssertLessThan(hp, 3000, "La puissance ne doit pas dépasser 3000 ch (\(car.displayName)).")
            }
        }
    }

    // Test 26 : Présence des Supercars phares
    @MainActor
    func testCatalogueLocalPresenceSupercars() {
        let viewModel = CarViewModel()
        let noms = viewModel.catalogueLocal.map { $0.displayName.lowercased() }

        XCTAssertTrue(noms.contains(where: { $0.contains("tourbillon") }), "Bugatti Tourbillon doit être présente.")
        XCTAssertTrue(noms.contains(where: { $0.contains("f80") }), "Ferrari F80 doit être présente.")
        XCTAssertTrue(noms.contains(where: { $0.contains("gt3 rs") }), "Porsche 911 GT3 RS doit être présente.")
    }

    // Test 27 : Présence des Citadines populaires européennes
    @MainActor
    func testCatalogueLocalPresenceCitadines() {
        let viewModel = CarViewModel()
        let noms = viewModel.catalogueLocal.map { $0.displayName.lowercased() }

        XCTAssertTrue(noms.contains(where: { $0.contains("clio") }), "Renault Clio doit être présente.")
        XCTAssertTrue(noms.contains(where: { $0.contains("208") }), "Peugeot 208 doit être présente.")
        XCTAssertTrue(noms.contains(where: { $0.contains("golf") }), "Volkswagen Golf doit être présente.")
    }

    // Test 28 : Noms de marques et modèles non vides
    @MainActor
    func testCatalogueLocalNomsNonVides() {
        let viewModel = CarViewModel()
        for car in viewModel.catalogueLocal {
            XCTAssertFalse((car.Make_Name ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
            XCTAssertFalse((car.Model_Name ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - 5. Tests Recherche & Recherche Dynamique

    // Test 29 : Recherche exacte par marque
    @MainActor
    func testRechercheExacteMarque() async {
        let viewModel = CarViewModel()
        await viewModel.fetchCars(searchQuery: "Porsche")
        XCTAssertFalse(viewModel.cars.isEmpty)
        let toutPorsche = viewModel.cars.allSatisfy {
            ($0.Make_Name ?? "").localizedCaseInsensitiveContains("Porsche") ||
            ($0.Model_Name ?? "").localizedCaseInsensitiveContains("Porsche")
        }
        XCTAssertTrue(toutPorsche, "Tous les véhicules retournés doivent être liés à Porsche.")
    }

    // Test 30 : Recherche insensible à la casse
    @MainActor
    func testRechercheInsensibleCasse() async {
        let vm1 = CarViewModel()
        let vm2 = CarViewModel()
        await vm1.fetchCars(searchQuery: "ferrari")
        await vm2.fetchCars(searchQuery: "FERRARI")

        XCTAssertEqual(vm1.cars.count, vm2.cars.count, "La recherche doit donner le même nombre de résultats en minuscule et majuscule.")
    }

    // Test 31 : Recherche avec espaces superflus
    @MainActor
    func testRechercheAvecEspacesSuperflus() async {
        let vm = CarViewModel()
        await vm.fetchCars(searchQuery: "   Alpine   ")
        XCTAssertFalse(vm.cars.isEmpty)
        let toutAlpine = vm.cars.allSatisfy {
            ($0.Make_Name ?? "").localizedCaseInsensitiveContains("Alpine") ||
            ($0.Model_Name ?? "").localizedCaseInsensitiveContains("Alpine")
        }
        XCTAssertTrue(toutAlpine)
    }

    // Test 32 : Recherche par nom de modèle numérique
    @MainActor
    func testRechercheParModeleNumerique() async {
        let vm = CarViewModel()
        await vm.fetchCars(searchQuery: "911")
        XCTAssertFalse(vm.cars.isEmpty)
        let tous911 = vm.cars.allSatisfy { ($0.Model_Name ?? "").contains("911") }
        XCTAssertTrue(tous911)
    }

    // Test 33 : Recherche infructueuse retourne une liste vide
    @MainActor
    func testRechercheInfructueuse() async {
        let vm = CarViewModel()
        await vm.fetchCars(searchQuery: "VehiculeInexistant12345XYZ")
        XCTAssertTrue(vm.cars.isEmpty, "Une recherche inexistante doit retourner 0 véhicule.")
        XCTAssertEqual(vm.voituresAffichees.count, 0)
    }

    // Test 34 : Recherche par caractères spéciaux et tirets
    @MainActor
    func testRechercheCaracteresSpeciaux() async {
        let vm = CarViewModel()
        await vm.fetchCars(searchQuery: "e-tron")
        XCTAssertFalse(vm.cars.isEmpty)
    }

    // Test 35 : Effacement de recherche restaure la sélection populaire
    @MainActor
    func testRechercheDynamiqueRestaurationPopulaire() async {
        let vm = CarViewModel()
        await vm.fetchCars(searchQuery: "Mustang")
        XCTAssertFalse(vm.cars.isEmpty)

        await vm.fetchCars(searchQuery: "")
        XCTAssertFalse(vm.cars.isEmpty)
        XCTAssertEqual(vm.cars.count, vm.catalogueLocal.count)
    }

    // MARK: - 6. Tests Pagination & Optimisation Performance

    // Test 36 : Taille de page par défaut est de 20
    @MainActor
    func testTaillePageParDefautVingt() {
        let vm = CarViewModel()
        XCTAssertEqual(vm.taillePage, 20)
    }

    // Test 37 : Affichage initial limité à 20 éléments
    @MainActor
    func testAffichageInitialLimiteVingt() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        XCTAssertEqual(vm.voituresAffichees.count, 20)
    }

    // Test 38 : Incrémentation successive de la pagination (20 -> 40 -> 60)
    @MainActor
    func testIncrementationPagination() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        XCTAssertEqual(vm.voituresAffichees.count, 20)

        vm.chargerPageSuivante()
        XCTAssertEqual(vm.voituresAffichees.count, 40)

        vm.chargerPageSuivante()
        XCTAssertEqual(vm.voituresAffichees.count, 60)
    }

    // Test 39 : Drapeau peutChargerPlus vrai tant qu'il reste des éléments
    @MainActor
    func testPeutChargerPlusIndicateur() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        XCTAssertTrue(vm.peutChargerPlus)
    }

    // Test 40 : Drapeau peutChargerPlus faux en fin de catalogue
    @MainActor
    func testPeutChargerPlusFauxEnFin() async {
        let vm = CarViewModel()
        await vm.fetchCars(searchQuery: "Chiron")
        // Afficher tous les éléments
        while vm.peutChargerPlus {
            vm.chargerPageSuivante()
        }
        XCTAssertFalse(vm.peutChargerPlus)
        XCTAssertEqual(vm.voituresAffichees.count, vm.cars.count)
    }

    // Test 41 : Réinitialisation stricte de la pagination lors du changement de filtre
    @MainActor
    func testPaginationResetSurChangementFiltre() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.chargerPageSuivante()
        vm.chargerPageSuivante()
        XCTAssertEqual(vm.voituresAffichees.count, 60)

        vm.appliquerFiltres(energie: .electrique)
        XCTAssertEqual(vm.limitePagination, 20)
        XCTAssertLessThanOrEqual(vm.voituresAffichees.count, 20)
    }

    // MARK: - 7. Tests Filtres Avancés Énergie & Puissance

    // Test 42 : Filtre Électrique pur
    @MainActor
    func testFiltreEnergieElectrique() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.appliquerFiltres(energie: .electrique)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            let fuel = (car.fuelType ?? "").lowercased()
            XCTAssertTrue(fuel.contains("electr") || fuel.contains("ev"), "Chaque voiture filtrée doit être électrique: \(car.displayName)")
        }
    }

    // Test 43 : Filtre Hybride pur
    @MainActor
    func testFiltreEnergieHybride() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.appliquerFiltres(energie: .hybride)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            let fuel = (car.fuelType ?? "").lowercased()
            XCTAssertTrue(fuel.contains("hybri") || fuel.contains("phev"), "Chaque voiture filtrée doit être hybride: \(car.displayName)")
        }
    }

    // Test 44 : Filtre Essence pur (incluant petrol et gas)
    @MainActor
    func testFiltreEnergieEssence() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.appliquerFiltres(energie: .essence)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            let fuel = (car.fuelType ?? "").lowercased()
            XCTAssertTrue(fuel.contains("petrol") || fuel.contains("gas") || fuel.contains("essence"))
        }
    }

    // Test 45 : Filtre Diesel pur
    @MainActor
    func testFiltreEnergieDiesel() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.appliquerFiltres(energie: .diesel)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            let fuel = (car.fuelType ?? "").lowercased()
            XCTAssertTrue(fuel.contains("diesel"))
        }
    }

    // Test 46 : Filtre Puissance > 300 ch
    @MainActor
    func testFiltrePuissancePlusDe300() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.appliquerFiltres(puissance: .plusDe300)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            XCTAssertGreaterThanOrEqual(car.horsepower ?? 0, 300)
        }
    }

    // Test 47 : Filtre Puissance > 500 ch
    @MainActor
    func testFiltrePuissancePlusDe500() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.appliquerFiltres(puissance: .plusDe500)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            XCTAssertGreaterThanOrEqual(car.horsepower ?? 0, 500)
        }
    }

    // Test 48 : Combinaison simultanée Énergie + Puissance (Électrique & > 500 ch)
    @MainActor
    func testFiltreCombineEnergieEtPuissance() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        vm.appliquerFiltres(energie: .electrique, puissance: .plusDe500)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            let fuel = (car.fuelType ?? "").lowercased()
            XCTAssertTrue(fuel.contains("electr") || fuel.contains("ev"))
            XCTAssertGreaterThanOrEqual(car.horsepower ?? 0, 500)
        }
    }

    // Test 49 : Réinitialisation complète des filtres restaure les paramètres par défaut
    @MainActor
    func testReinitialisationCompleteFiltres() async {
        let vm = CarViewModel()
        await vm.fetchTrendingCars()
        let countInitial = vm.cars.count

        vm.appliquerFiltres(energie: .diesel, puissance: .plusDe300)
        XCTAssertEqual(vm.filtreEnergieActif, .diesel)
        XCTAssertEqual(vm.filtrePuissanceActif, .plusDe300)

        vm.reinitialiserFiltres()
        XCTAssertEqual(vm.filtreEnergieActif, .tous)
        XCTAssertEqual(vm.filtrePuissanceActif, .toutes)
        XCTAssertEqual(vm.cars.count, countInitial)
    }

    // MARK: - 8. Tests Nouveautés 6 Mois

    // Test 50 : Filtrage strict des millésimes récents (>= 2025)
    @MainActor
    func testNouveautesAnneesStrictes2025Et2026() async {
        let vm = CarViewModel()
        await vm.fetchNouveautes()

        XCTAssertFalse(vm.cars.isEmpty, "L'onglet nouveautés ne doit pas être vide.")
        for car in vm.cars {
            let annee = car.year ?? 0
            XCTAssertGreaterThanOrEqual(annee, 2025, "Chaque nouveauté doit être de 2025 ou 2026 (\(car.displayName)).")
        }
    }

    // Test 51 : Pagination active sur l'onglet Nouveautés
    @MainActor
    func testNouveautesPaginationParVingt() async {
        let vm = CarViewModel()
        await vm.fetchNouveautes()

        XCTAssertGreaterThan(vm.cars.count, 20, "Les nouveautés doivent comporter plus de 20 modèles pour paginer.")
        XCTAssertEqual(vm.voituresAffichees.count, 20, "La première page doit afficher 20 véhicules.")

        vm.chargerPageSuivante()
        XCTAssertGreaterThan(vm.voituresAffichees.count, 20, "Le chargement de page suivante doit étendre la liste.")
    }

    // Test 52 : Présence des dernières supercars 2025-2026
    @MainActor
    func testNouveautesPresenceSupercars2025() async {
        let vm = CarViewModel()
        await vm.fetchNouveautes()

        let noms = vm.cars.map { $0.displayName.lowercased() }
        XCTAssertTrue(noms.contains(where: { $0.contains("f80") }))
        XCTAssertTrue(noms.contains(where: { $0.contains("tourbillon") }))
        XCTAssertTrue(noms.contains(where: { $0.contains("w1") }))
    }

    // Test 53 : Nouveautés compatibles avec filtre énergie
    @MainActor
    func testNouveautesFiltreElectrique() async {
        let vm = CarViewModel()
        await vm.fetchNouveautes()
        vm.appliquerFiltres(energie: .electrique)

        XCTAssertFalse(vm.cars.isEmpty)
        for car in vm.cars {
            XCTAssertGreaterThanOrEqual(car.year ?? 0, 2025)
            let fuel = (car.fuelType ?? "").lowercased()
            XCTAssertTrue(fuel.contains("electr") || fuel.contains("ev"))
        }
    }

    // MARK: - 9. Tests Comparateur Duel (Pokédex Face-à-Face)

    // Test 54 : Égalité parfaite entre deux véhicules identiques
    func testComparateurDuelEgaliteParfaite() {
        let c1 = Car(Make_Name: "Porsche", Model_Name: "911 GT3", year: 2024, displacement: 4.0, highwayMpg: 20, horsepower: 510)
        let c2 = Car(Make_Name: "Porsche", Model_Name: "911 GT3", year: 2024, displacement: 4.0, highwayMpg: 20, horsepower: 510)

        let duel = ComparaisonVehicules(car1: c1, car2: c2)
        XCTAssertNil(duel.gagnantPuissance)
        XCTAssertNil(duel.gagnantCylindree)
        XCTAssertNil(duel.gagnantConso)
        XCTAssertEqual(duel.scoreCar1, 0)
        XCTAssertEqual(duel.scoreCar2, 0)
        XCTAssertEqual(duel.verdictTexte, "Égalité parfaite entre les deux bolides !")
    }

    // Test 55 : Victoire nette de la Voiture 1
    func testComparateurDuelVictoireVoiture1() {
        let c1 = Car(Make_Name: "Bugatti", Model_Name: "Tourbillon", year: 2026, displacement: 8.3, highwayMpg: 18, horsepower: 1800)
        let c2 = Car(Make_Name: "Alpine", Model_Name: "A110", year: 2022, displacement: 1.8, highwayMpg: 35, horsepower: 252)

        let duel = ComparaisonVehicules(car1: c1, car2: c2)
        XCTAssertEqual(duel.gagnantPuissance, 1, "Bugatti a plus de ch.")
        XCTAssertEqual(duel.gagnantCylindree, 1, "Bugatti a plus de cylindrée.")
        XCTAssertEqual(duel.gagnantConso, 2, "Alpine consomme moins (35 > 18 MPG).")

        XCTAssertEqual(duel.scoreCar1, 2)
        XCTAssertEqual(duel.scoreCar2, 1)
        XCTAssertTrue(duel.verdictTexte.contains("Bugatti Tourbillon"))
    }

    // Test 56 : Victoire nette de la Voiture 2
    func testComparateurDuelVictoireVoiture2() {
        let c1 = Car(Make_Name: "Peugeot", Model_Name: "208", year: 2023, displacement: 1.2, highwayMpg: 45, horsepower: 100)
        let c2 = Car(Make_Name: "Ferrari", Model_Name: "F80", year: 2025, displacement: 3.0, highwayMpg: 18, horsepower: 1200)

        let duel = ComparaisonVehicules(car1: c1, car2: c2)
        XCTAssertEqual(duel.gagnantPuissance, 2)
        XCTAssertEqual(duel.gagnantCylindree, 2)
        XCTAssertEqual(duel.gagnantConso, 1)

        XCTAssertEqual(duel.scoreCar1, 1)
        XCTAssertEqual(duel.scoreCar2, 2)
        XCTAssertTrue(duel.verdictTexte.contains("Ferrari F80"))
    }

    // Test 57 : Comparateur avec valeurs optionnelles Nil
    func testComparateurDuelGestionDonneesNil() {
        let c1 = Car(Make_Name: "Proto1", Model_Name: "X", horsepower: nil)
        let c2 = Car(Make_Name: "Proto2", Model_Name: "Y", horsepower: 200)

        let duel = ComparaisonVehicules(car1: c1, car2: c2)
        XCTAssertNil(duel.gagnantPuissance, "La comparaison est indécise (nil) si l'une des deux données est manquante.")
    }

    // Test 58 : Comparateur quand les deux valeurs sont Nil
    func testComparateurDuelDeuxValeursNil() {
        let c1 = Car(Make_Name: "Proto1", Model_Name: "X", displacement: nil)
        let c2 = Car(Make_Name: "Proto2", Model_Name: "Y", displacement: nil)

        let duel = ComparaisonVehicules(car1: c1, car2: c2)
        XCTAssertNil(duel.gagnantCylindree)
    }

    // Test 59 : Comparaison Consommation Autoroute
    func testComparateurDuelConsommationAutoroute() {
        let c1 = Car(Make_Name: "Clio", Model_Name: "dCi", highwayMpg: 55)
        let c2 = Car(Make_Name: "Mustang", Model_Name: "V8", highwayMpg: 22)

        let duel = ComparaisonVehicules(car1: c1, car2: c2)
        XCTAssertEqual(duel.gagnantConso, 1)
    }

    // Test 60 : Détection de l'égalité de score
    func testComparateurDuelScoreEgalitaire() {
        let c1 = Car(Make_Name: "A", Model_Name: "1", highwayMpg: 30, horsepower: 500)
        let c2 = Car(Make_Name: "B", Model_Name: "2", highwayMpg: 40, horsepower: 400)

        let duel = ComparaisonVehicules(car1: c1, car2: c2)
        XCTAssertEqual(duel.scoreCar1, 1)
        XCTAssertEqual(duel.scoreCar2, 1)
        XCTAssertEqual(duel.verdictTexte, "Égalité parfaite entre les deux bolides !")
    }

    // MARK: - 10. Tests Mini-Jeu Quiz Pokédex

    // Test 61 : Génération valide d'une question de quiz
    @MainActor
    func testGenerationQuestionQuizStructureValide() {
        let vm = CarViewModel()
        let question = vm.genererQuestionQuiz()

        XCTAssertNotNil(question)
        if let q = question {
            XCTAssertEqual(q.propositions.count, 4)
            XCTAssertTrue((0...3).contains(q.bonneReponseIndex))
            XCTAssertEqual(q.propositions[q.bonneReponseIndex].id, q.voitureCible.id)
        }
    }

    // Test 62 : Les 4 choix proposés sont 4 véhicules strictement distincts
    @MainActor
    func testQuizPropositionsSansDoublon() {
        let vm = CarViewModel()
        for _ in 1...10 {
            if let q = vm.genererQuestionQuiz() {
                let ids = Set(q.propositions.map { $0.id })
                XCTAssertEqual(ids.count, 4, "Chaque question doit proposer 4 véhicules strictement différents.")
            }
        }
    }

    // Test 63 : La voiture cible appartient obligatoirement aux propositions
    @MainActor
    func testQuizCibleToujoursPresenteDansPropositions() {
        let vm = CarViewModel()
        for _ in 1...10 {
            if let q = vm.genererQuestionQuiz() {
                let cibleTrouvee = q.propositions.contains(where: { $0.id == q.voitureCible.id })
                XCTAssertTrue(cibleTrouvee)
            }
        }
    }

    // Test 64 : Génération de questions multiples indépendantes
    @MainActor
    func testQuizQuestionsSuccessivesIndependantes() {
        let vm = CarViewModel()
        let q1 = vm.genererQuestionQuiz()
        let q2 = vm.genererQuestionQuiz()

        XCTAssertNotNil(q1)
        XCTAssertNotNil(q2)
        XCTAssertNotEqual(q1?.id, q2?.id, "Deux questions doivent avoir des identifiants distincts.")
    }

    // Test 65 : Sélection prioritaire de marques emblématiques pour le quiz
    @MainActor
    func testQuizCibleMarqueEmblematique() {
        let vm = CarViewModel()
        let q = vm.genererQuestionQuiz()
        XCTAssertNotNil(q?.voitureCible.Make_Name)
    }

    // Test 66 : Quiz non générable sur catalogue trop restreint (< 4 éléments)
    @MainActor
    func testQuizCatalogueTropPetitRenvoieNil() {
        let vm = CarViewModel()
        vm.catalogueLocal = [
            Car(Make_Name: "A", Model_Name: "1"),
            Car(Make_Name: "B", Model_Name: "2")
        ]
        XCTAssertNil(vm.genererQuestionQuiz(), "Le générateur doit renvoyer nil si le catalogue comporte moins de 4 éléments.")
    }

    // MARK: - 11. Tests Recherche Spécifique & Trouver Véhicule

    // Test 67 : Trouver véhicule par identifiant UUID exact
    @MainActor
    func testTrouverVehiculeParId() {
        let vm = CarViewModel()
        guard let premier = vm.catalogueLocal.first else {
            XCTFail("Le catalogue doit contenir au moins un véhicule.")
            return
        }

        let trouve = vm.trouverVehicule(parId: premier.id)
        XCTAssertEqual(trouve?.id, premier.id)
        XCTAssertEqual(trouve?.displayName, premier.displayName)
    }

    // Test 68 : Trouver véhicule par Marque et Modèle
    @MainActor
    func testTrouverVehiculeParMarqueEtModele() {
        let vm = CarViewModel()
        let trouve = vm.trouverVehicule(marque: "Porsche", modele: "911 Carrera S")
        XCTAssertNotNil(trouve)
        XCTAssertEqual(trouve?.Make_Name?.lowercased(), "porsche")
    }

    // Test 69 : Recherche d'un véhicule inexistant renvoie nil
    @MainActor
    func testTrouverVehiculeInexistantRenvoieNil() {
        let vm = CarViewModel()
        let trouveId = vm.trouverVehicule(parId: UUID())
        XCTAssertNil(trouveId)

        let trouveNom = vm.trouverVehicule(marque: "MarqueInconnue", modele: "ModeleInconnu")
        XCTAssertNil(trouveNom)
    }

    // MARK: - 12. Tests Services Réseau & Cache (BrandLogo & Wikipédia)

    // Test 70 : Service de Logo Marque et normalisation d'URL
    func testBrandLogoServiceNormalisationURL() {
        let service = BrandLogoService.shared
        let urlPorsche = service.urlLogo(pour: "Porsche")
        let urlMercedes = service.urlLogo(pour: "Mercedes-Benz")
        let urlAston = service.urlLogo(pour: "Aston Martin")

        XCTAssertNotNil(urlPorsche)
        XCTAssertNotNil(urlMercedes)
        XCTAssertNotNil(urlAston)
        XCTAssertTrue(urlPorsche?.absoluteString.contains("porsche") ?? false)
    }

    // Test 71 : Service de Logo avec chaîne vide ou inconnue
    func testBrandLogoServiceMarqueInconnue() {
        let service = BrandLogoService.shared
        XCTAssertNil(service.urlLogo(pour: ""))
        XCTAssertNil(service.urlLogo(pour: "   "))
    }

    // Test 72 : Service Wikipédia et assainissement des variantes
    func testWikipediaServiceNettoyageVariantes() async {
        let service = WikipediaService.shared
        let detail = await service.chargerInfosVehicule(marque: "Peugeot", modele: "508 PSE (Peugeot Sport Engineered)")
        if let detail = detail {
            XCTAssertFalse(detail.titre.isEmpty)
            if let photo = detail.photoUrl {
                XCTAssertFalse(photo.hasSuffix(".svg"), "Les fichiers vectoriels SVG de logos doivent être rejetés.")
                XCTAssertFalse(photo.lowercased().contains("logo"))
            }
        }
    }

    // MARK: - 13. Tests Modèle Persistant SwiftData (FavoriteCar)

    // Test 73 : Création et propriétés du modèle FavoriteCar
    func testModeleFavoriteCarProprietes() {
        let favori = FavoriteCar(make: "Ferrari", model: "F40", year: 1987)
        XCTAssertEqual(favori.make, "Ferrari")
        XCTAssertEqual(favori.model, "F40")
        XCTAssertEqual(favori.year, 1987)
        XCTAssertEqual(favori.id, "ferrari-f40")
        XCTAssertEqual(favori.displayName, "Ferrari F40")
        XCTAssertEqual(favori.displaySubtitle, "1987 - Spécification Standard")
        XCTAssertNotNil(favori.timestamp)
    }

    // Test 74 : Unicité de la clé d'identification dans FavoriteCar
    func testModeleFavoriteCarCleUnique() {
        let fav1 = FavoriteCar(make: "Porsche", model: "911 GT3", year: 2022)
        let fav2 = FavoriteCar(make: "PORSCHE", model: "911 gt3", year: 2024)
        XCTAssertEqual(fav1.id, fav2.id, "La clé composite unique doit être normalisée en minuscules.")
    }

    // MARK: - 14. Tests Menu Tiroir Latéral & Sections de Navigation

    // Test 75 : Complétude et ordre des sections de navigation
    func testSectionNavigationNombreEtOrdre() {
        let sections = SectionNavigation.allCases
        XCTAssertEqual(sections.count, 7, "Le menu tiroir doit comporter exactement 7 sections.")
        XCTAssertEqual(sections, [.accueil, .collection, .duel, .quiz, .decouverte, .favoris, .aPropos])
    }

    // Test 76 : Titres complets en français pour chaque section
    func testSectionNavigationTitresComplets() {
        for section in SectionNavigation.allCases {
            XCTAssertFalse(section.titreComplet.isEmpty)
            XCTAssertFalse(section.rawValue.isEmpty)
        }
        XCTAssertEqual(SectionNavigation.accueil.titreComplet, "Accueil & Catalogue")
        XCTAssertEqual(SectionNavigation.collection.titreComplet, "Ma Collection")
        XCTAssertEqual(SectionNavigation.duel.titreComplet, "Mode Duel Face-à-Face")
        XCTAssertEqual(SectionNavigation.quiz.titreComplet, "Pokédex Quiz")
        XCTAssertEqual(SectionNavigation.decouverte.titreComplet, "Découverte Aléatoire")
        XCTAssertEqual(SectionNavigation.favoris.titreComplet, "Mes Favoris")
        XCTAssertEqual(SectionNavigation.aPropos.titreComplet, "À Propos d'AutoDex")
    }

    // Test 77 : Icônes SF Symbols valides
    func testSectionNavigationIconesSF() {
        for section in SectionNavigation.allCases {
            XCTAssertFalse(section.icone.isEmpty, "Chaque section doit définir une icône SF Symbol non vide.")
        }
        XCTAssertEqual(SectionNavigation.accueil.icone, "house.fill")
        XCTAssertEqual(SectionNavigation.collection.icone, "camera.fill")
        XCTAssertEqual(SectionNavigation.duel.icone, "arrow.left.arrow.right")
        XCTAssertEqual(SectionNavigation.quiz.icone, "gamecontroller.fill")
        XCTAssertEqual(SectionNavigation.decouverte.icone, "sparkles")
        XCTAssertEqual(SectionNavigation.favoris.icone, "heart.fill")
        XCTAssertEqual(SectionNavigation.aPropos.icone, "info.circle.fill")
    }

    // Test 78 : Badge de nouveauté sur la section Ma Collection
    func testSectionNavigationBadges() {
        XCTAssertEqual(SectionNavigation.collection.badgeTexte, "Nouveau")
        XCTAssertNil(SectionNavigation.accueil.badgeTexte)
        XCTAssertNil(SectionNavigation.duel.badgeTexte)
        XCTAssertNil(SectionNavigation.quiz.badgeTexte)
        XCTAssertNil(SectionNavigation.decouverte.badgeTexte)
        XCTAssertNil(SectionNavigation.aPropos.badgeTexte)
    }

    // Test 79 : Identifiant unique conforme au rawValue
    func testSectionNavigationIdentifiants() {
        for section in SectionNavigation.allCases {
            XCTAssertEqual(section.id, section.rawValue)
        }
    }
}
