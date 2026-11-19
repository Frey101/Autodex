//
//  CarViewModel.swift
//  Autodex
//
//  Created by Alyssia Frey on 29/05/2026.
//

import Foundation
import Observation

@Observable
class CarViewModel {
    // Liste des véhicules affichés dans l'interface
    var cars: [Car] = []
    var isLoading = false
    var errorMessage: String? = nil
    
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
            await MainActor.run {
                self.cars = resultatsLocaux
                self.isLoading = false
            }
            return
        }
        
        // 2. Si aucun résultat local et au moins 3 caractères, tentative via l'API NHTSA
        guard rechercheNettoyee.count >= 3 else {
            await MainActor.run {
                self.cars = []
                self.isLoading = false
            }
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
        
        // Si le catalogue local est présent, sélection des marques emblématiques
        if !catalogueLocal.isEmpty {
            let marquesPopulaires = [
                "porsche", "bmw", "audi", "mercedes-benz", "ferrari",
                "lamborghini", "ford", "renault", "peugeot", "volkswagen",
                "honda", "toyota", "abarth", "aston martin", "alfa romeo", "alpine"
            ]
            
            // Sélection d'échantillons variés par marque
            var selectionPopulaire: [Car] = []
            for marque in marquesPopulaires {
                let vehiculesMarque = catalogueLocal.filter {
                    ($0.Make_Name ?? "").lowercased() == marque
                }
                selectionPopulaire.append(contentsOf: vehiculesMarque.prefix(4))
            }
            
            let listeFinale = selectionPopulaire.shuffled()
            await MainActor.run {
                self.cars = listeFinale
                self.isLoading = false
            }
            return
        }
        
        // Fallback réseau si le fichier local n'était pas chargé
        await fetchTrendingCarsReseau()
    }
    
    // MARK: - Remplissage avec les nouveautés récentes (sorties des 6 derniers mois / 2024-2026)
    func fetchNewReleases() async {
        self.isLoading = true
        self.errorMessage = nil
        self.reinitialiserPagination()
        
        if !catalogueLocal.isEmpty {
            // Sélection des modèles récents (2024, 2025 et 2026) triés par récence et puissance
            let nouveautes = catalogueLocal.filter { car in
                guard let annee = car.year else { return false }
                return annee >= 2024
            }.sorted { (c1, c2) in
                let y1 = c1.year ?? 0
                let y2 = c2.year ?? 0
                if y1 != y2 {
                    return y1 > y2
                }
                return (c1.horsepower ?? 0) > (c2.horsepower ?? 0)
            }
            
            await MainActor.run {
                self.cars = nouveautes
                self.isLoading = false
            }
            return
        }
        
        // Fallback réseau si le catalogue local est indisponible
        let anneeCible = 2026
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/porsche/modelyear/\(anneeCible)?format=json"
        await effectuerRequeteReseau(urlString: urlString, anneeParDefaut: anneeCible)
    }
    private func fetchTrendingCarsReseau() async {
        let targetYear = 2026
        let brandsToMix = ["bmw", "audi", "mercedes", "honda", "fiat", "nissan", "volkswagen", "lamborghini", "porsche", "toyota"]
        var allMixedCars: [Car] = []
        
        await withTaskGroup(of: [Car].self) { group in
            for brand in brandsToMix {
                let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/\(brand)/modelyear/\(targetYear)?format=json"
                
                group.addTask {
                    guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                          let url = URL(string: encodedUrlString) else {
                        return []
                    }
                    
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let decodedResponse = try JSONDecoder().decode(NHTSAResponse.self, from: data)
                        return decodedResponse.Results.map { car -> Car in
                            var updatedCar = car
                            updatedCar.year = targetYear
                            return updatedCar
                        }
                    } catch {
                        return []
                    }
                }
            }
            
            for await brandCars in group {
                allMixedCars.append(contentsOf: brandCars)
            }
        }
        
        let finalShuffledList = allMixedCars.shuffled()
        await MainActor.run {
            if finalShuffledList.isEmpty {
                self.errorMessage = "Aucun résultat ou erreur de connexion."
            } else {
                self.cars = finalShuffledList
            }
            self.isLoading = false
        }
    }
    
    private func effectuerRequeteReseau(urlString: String, anneeParDefaut: Int) async {
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            await MainActor.run {
                self.errorMessage = "Erreur : Recherche invalide."
                self.isLoading = false
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                await MainActor.run {
                    self.errorMessage = "Erreur serveur ou véhicule introuvable."
                    self.isLoading = false
                }
                return
            }
            
            let decodedResponse = try JSONDecoder().decode(NHTSAResponse.self, from: data)
            let finalCars = decodedResponse.Results.map { car -> Car in
                var updatedCar = car
                updatedCar.year = anneeParDefaut
                return updatedCar
            }
            
            await MainActor.run {
                self.cars = finalCars
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Aucun véhicule trouvé pour cette recherche."
                self.isLoading = false
            }
        }
    }
}
