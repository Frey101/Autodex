//
//  CarViewModel.swift
//  Autodex
//
//  Created by Alyssia Frey on 29/05/2026.
//

import Foundation
import Observation

// MARK: - Énumérations des Filtres Avancés
enum FiltreEnergie: String, CaseIterable, Identifiable {
    case tous = "Tous"
    case electrique = "Électrique"
    case hybride = "Hybride"
    case essence = "Essence"
    case diesel = "Diesel"
    
    var id: String { rawValue }
    
    var icone: String {
        switch self {
        case .tous: return "sparkles"
        case .electrique: return "bolt.car.fill"
        case .hybride: return "leaf.arrow.triangle.circlepath"
        case .essence: return "fuelpump.fill"
        case .diesel: return "drop.fill"
        }
    }
}

enum FiltrePuissance: String, CaseIterable, Identifiable {
    case toutes = "Toutes"
    case plusDe300 = "> 300 ch"
    case plusDe500 = "> 500 ch"
    
    var id: String { rawValue }
    
    var minHp: Int? {
        switch self {
        case .toutes: return nil
        case .plusDe300: return 300
        case .plusDe500: return 500
        }
    }
}

// MARK: - Modèle de Comparaison Face-à-Face (Mode Duel)
struct ComparaisonVehicules {
    let car1: Car
    let car2: Car
    
    var gagnantPuissance: Int? {
        guard let hp1 = car1.horsepower, let hp2 = car2.horsepower else { return nil }
        if hp1 > hp2 { return 1 }
        if hp2 > hp1 { return 2 }
        return nil
    }
    
    var gagnantConso: Int? {
        guard let mpg1 = car1.highwayMpg, let mpg2 = car2.highwayMpg else { return nil }
        if mpg1 > mpg2 { return 1 }
        if mpg2 > mpg1 { return 2 }
        return nil
    }
    
    var gagnantCylindree: Int? {
        guard let d1 = car1.displacement, let d2 = car2.displacement else { return nil }
        if d1 > d2 { return 1 }
        if d2 > d1 { return 2 }
        return nil
    }
    
    var scoreCar1: Int {
        var s = 0
        if gagnantPuissance == 1 { s += 1 }
        if gagnantConso == 1 { s += 1 }
        if gagnantCylindree == 1 { s += 1 }
        return s
    }
    
    var scoreCar2: Int {
        var s = 0
        if gagnantPuissance == 2 { s += 1 }
        if gagnantConso == 2 { s += 1 }
        if gagnantCylindree == 2 { s += 1 }
        return s
    }
    
    var verdictTexte: String {
        if scoreCar1 > scoreCar2 {
            return "\(car1.displayName) remporte le duel !"
        } else if scoreCar2 > scoreCar1 {
            return "\(car2.displayName) remporte le duel !"
        } else {
            return "Égalité parfaite entre les deux bolides !"
        }
    }
}

// MARK: - Modèle de Question de Quiz Pokédex
struct QuestionQuiz: Identifiable {
    let id = UUID()
    let voitureCible: Car
    let propositions: [Car]
    let bonneReponseIndex: Int
}

@Observable
@MainActor
class CarViewModel {
    // Liste des véhicules affichés dans l'interface
    var cars: [Car] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    // MARK: - Filtres Avancés
    var filtreEnergieActif: FiltreEnergie = .tous
    var filtrePuissanceActif: FiltrePuissance = .toutes
    
    // Liste source non filtrée
    private var listeSource: [Car] = []
    
    // MARK: - Gestion de la Pagination (20 éléments par page)
    var limitePagination: Int = 20
    let taillePage: Int = 20
    
    // Véhicules actuellement découpés pour l'affichage paginé
    var carsAffichees: [Car] {
        Array(cars.prefix(limitePagination))
    }
    
    var peutChargerPlus: Bool {
        limitePagination < cars.count
    }
    
    func chargerPageSuivante() {
        guard peutChargerPlus else { return }
        limitePagination += taillePage
    }
    
    func reinitialiserPagination() {
        limitePagination = taillePage
    }
    
    // Cache local de l'ensemble du catalogue embarqué
    private(set) var catalogueLocal: [Car] = []
    
    init() {
        chargerCatalogueLocal()
    }
    
    // MARK: - Chargement du catalogue local embarqué
    func chargerCatalogueLocal() {
        guard let url = Bundle.main.url(forResource: "car_details", withExtension: "json") else {
            print("Fichier car_details.json introuvable dans le bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let details = try JSONDecoder().decode([DetailVehiculeData].self, from: data)
            self.catalogueLocal = details.map { Car(fromDetail: $0) }
        } catch {
            print("Erreur lors du décodage du catalogue local : \(error)")
        }
    }
    
    // MARK: - Application des Filtres
    func appliquerFiltres(energie: FiltreEnergie? = nil, puissance: FiltrePuissance? = nil) {
        if let energie = energie {
            filtreEnergieActif = energie
        }
        if let puissance = puissance {
            filtrePuissanceActif = puissance
        }
        
        reinitialiserPagination()
        filtrerListeCourante()
    }
    
    func reinitialiserFiltres() {
        filtreEnergieActif = .tous
        filtrePuissanceActif = .toutes
        self.cars = listeSource
        reinitialiserPagination()
    }
    
    private func filtrerListeCourante() {
        var resultats = listeSource
        
        // 1. Filtrage Énergie
        switch filtreEnergieActif {
        case .tous:
            break
        case .electrique:
            resultats = resultats.filter {
                let fuel = ($0.fuelType ?? "").lowercased()
                return fuel.contains("electric") || fuel.contains("electrique")
            }
        case .hybride:
            resultats = resultats.filter {
                let fuel = ($0.fuelType ?? "").lowercased()
                return fuel.contains("hybrid") || fuel.contains("hybride")
            }
        case .essence:
            resultats = resultats.filter {
                let fuel = ($0.fuelType ?? "").lowercased()
                return fuel.contains("petrol") || fuel.contains("gasoline") || fuel.contains("essence")
            }
        case .diesel:
            resultats = resultats.filter {
                let fuel = ($0.fuelType ?? "").lowercased()
                return fuel.contains("diesel")
            }
        }
        
        // 2. Filtrage Puissance
        if let minHp = filtrePuissanceActif.minHp {
            resultats = resultats.filter { ($0.horsepower ?? 0) >= minHp }
        }
        
        self.cars = resultats
    }
    
    // MARK: - Résolution d'un favori vers sa fiche complète Car
    func trouverVehicule(pour favori: FavoriteCar) -> Car {
        let makeFav = favori.make.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let modelFav = favori.model.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if let match = catalogueLocal.first(where: {
            let carMake = ($0.Make_Name ?? "").lowercased()
            let carModel = ($0.Model_Name ?? "").lowercased()
            return (carMake == makeFav || carMake.contains(makeFav)) &&
                   (carModel == modelFav || carModel.contains(modelFav) || modelFav.contains(carModel))
        }) {
            return match
        }
        
        // Reconstitution minimale si non présent dans le catalogue local
        return Car(
            Make_Name: favori.make,
            Model_Name: favori.model,
            year: favori.year
        )
    }
    
    // MARK: - Recherche par marque ou modèle (dynamique)
    func fetchCars(searchQuery: String) async {
        let rechercheNettoyee = searchQuery.trimmingCharacters(in: .whitespaces)
        
        // Si la recherche est vide, on recharge instantanément les véhicules populaires
        if rechercheNettoyee.isEmpty {
            await fetchTrendingCars()
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.reinitialiserPagination()
        
        // 1. Recherche instantanée dans le catalogue local
        let resultatsLocaux = catalogueLocal.filter { car in
            let marque = car.Make_Name ?? ""
            let modele = car.Model_Name ?? ""
            let nomComplet = car.displayName
            
            return nomComplet.localizedCaseInsensitiveContains(rechercheNettoyee) ||
                   marque.localizedCaseInsensitiveContains(rechercheNettoyee) ||
                   modele.localizedCaseInsensitiveContains(rechercheNettoyee)
        }
        
        if !resultatsLocaux.isEmpty {
            self.listeSource = resultatsLocaux
            self.filtrerListeCourante()
            self.isLoading = false
            return
        }
        
        // 2. Si aucun résultat local et au moins 3 caractères, tentative via l'API NHTSA
        guard rechercheNettoyee.count >= 3 else {
            self.listeSource = []
            self.cars = []
            self.isLoading = false
            return
        }
        
        let anneeCible = 2025
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/\(rechercheNettoyee)/modelyear/\(anneeCible)?format=json"
        await effectuerRequeteReseau(urlString: urlString, anneeParDefaut: anneeCible)
    }
    
    // MARK: - Remplissage de l'écran d'accueil avec les véhicules populaires
    func fetchTrendingCars() async {
        self.isLoading = true
        self.errorMessage = nil
        self.reinitialiserPagination()
        
        // Si le catalogue local est présent, sélection ordonnée : marques emblématiques en tête, puis reste du catalogue
        if !catalogueLocal.isEmpty {
            let marquesPopulaires: Set<String> = [
                "porsche", "bmw", "audi", "mercedes-benz", "ferrari",
                "lamborghini", "ford", "renault", "peugeot", "volkswagen",
                "honda", "toyota", "abarth", "aston martin", "alfa romeo", "alpine",
                "bugatti", "mclaren", "chevrolet", "maserati", "lotus", "nissan"
            ]
            
            // 1. Les véhicules des marques emblématiques (mélangés équitablement en priorité)
            let vehiculesPopulaires = catalogueLocal.filter { car in
                marquesPopulaires.contains((car.Make_Name ?? "").lowercased())
            }.shuffled()
            
            // 2. Le reste du catalogue complet pour alimenter la pagination continue
            let autresVehicules = catalogueLocal.filter { car in
                !marquesPopulaires.contains((car.Make_Name ?? "").lowercased())
            }.shuffled()
            
            self.listeSource = vehiculesPopulaires + autresVehicules
            self.filtrerListeCourante()
            self.isLoading = false
            return
        }
        
        // Fallback réseau si le fichier local n'était pas chargé
        await fetchTrendingCarsReseau()
    }
    
    // MARK: - Remplissage avec les nouveautés récentes (sorties des 6 derniers mois / millésimes 2025-2026)
    func fetchNewReleases() async {
        self.isLoading = true
        self.errorMessage = nil
        self.reinitialiserPagination()
        
        if !catalogueLocal.isEmpty {
            // Sélection STRICTE des modèles sortis durant les 6 derniers mois (>= 2025)
            let nouveautes = catalogueLocal.filter { car in
                guard let annee = car.year else { return false }
                return annee >= 2025
            }.sorted { (c1, c2) in
                let y1 = c1.year ?? 0
                let y2 = c2.year ?? 0
                if y1 != y2 {
                    return y1 > y2
                }
                return (c1.horsepower ?? 0) > (c2.horsepower ?? 0)
            }
            
            self.listeSource = nouveautes
            self.filtrerListeCourante()
            self.isLoading = false
            return
        }
        
        // Fallback réseau si le catalogue local est indisponible
        let anneeCible = 2026
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/porsche/modelyear/\(anneeCible)?format=json"
        await effectuerRequeteReseau(urlString: urlString, anneeParDefaut: anneeCible)
    }
    
    // MARK: - Générateur de Question de Quiz Pokédex
    func genererQuestionQuiz() -> QuestionQuiz? {
        guard catalogueLocal.count >= 4 else { return nil }
        guard let cible = catalogueLocal.randomElement() else { return nil }
        
        var distracteurs: [Car] = []
        // Même marque en priorité si possible
        let memeMarque = catalogueLocal.filter {
            $0.id != cible.id && $0.Make_Name?.lowercased() == cible.Make_Name?.lowercased()
        }.shuffled()
        distracteurs.append(contentsOf: memeMarque.prefix(2))
        
        // Autres véhicules aléatoires pour compléter à 3 distracteurs
        let autres = catalogueLocal.filter { c in
            c.id != cible.id && !distracteurs.contains(where: { d in d.id == c.id })
        }.shuffled()
        distracteurs.append(contentsOf: autres.prefix(3 - distracteurs.count))
        
        var toutesPropositions = distracteurs + [cible]
        toutesPropositions.shuffle()
        
        guard let bonneIndex = toutesPropositions.firstIndex(where: { $0.id == cible.id }) else {
            return nil
        }
        
        return QuestionQuiz(
            voitureCible: cible,
            propositions: toutesPropositions,
            bonneReponseIndex: bonneIndex
        )
    }
    
    // MARK: - Requêtes Réseau NHTSA (Repli de secours)
    private func fetchTrendingCarsReseau() async {
        let targetYear = 2026
        let brandsToMix = ["bmw", "audi", "mercedes", "honda", "fiat", "nissan", "volkswagen", "lamborghini", "porsche", "toyota"]
        var allMixedCars: [Car] = []
        
        await withTaskGroup(of: [Car].self) { group in
            for brand in brandsToMix {
                let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/\(brand)/modelyear/\(targetYear)?format=json"
                group.addTask {
                    guard let url = URL(string: urlString) else { return [] }
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let response = try JSONDecoder().decode(NHTSAResponse.self, from: data)
                        return response.Results.prefix(4).map { car in
                            var c = car
                            c.year = targetYear
                            return c
                        }
                    } catch {
                        return []
                    }
                }
            }
            
            for await carsFromBrand in group {
                allMixedCars.append(contentsOf: carsFromBrand)
            }
        }
        
        self.listeSource = allMixedCars.shuffled()
        self.filtrerListeCourante()
        self.isLoading = false
    }
    
    private func effectuerRequeteReseau(urlString: String, anneeParDefaut: Int) async {
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL Invalide"
            self.isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(NHTSAResponse.self, from: data)
            
            self.listeSource = decodedResponse.Results.map { car in
                var c = car
                c.year = anneeParDefaut
                return c
            }
            self.filtrerListeCourante()
            self.isLoading = false
        } catch {
            self.errorMessage = "Échec du chargement : \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
