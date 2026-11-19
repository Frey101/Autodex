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
    
    // MARK: - Recherche par marque ou modèle
    func fetchCars(searchQuery: String) async {
        let rechercheNettoyee = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !rechercheNettoyee.isEmpty else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
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
        
        // 2. Si aucun résultat local, fallback sur l'API NHTSA
        let anneeCible = 2025
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/\(rechercheNettoyee)/modelyear/\(anneeCible)?format=json"
        await effectuerRequeteReseau(urlString: urlString, anneeParDefaut: anneeCible)
    }
    
    // MARK: - Remplissage de l'écran d'accueil avec les véhicules populaires
    func fetchTrendingCars() async {
        self.isLoading = true
        self.errorMessage = nil
        
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
    
    // MARK: - Fallback réseau (NHTSA)
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
