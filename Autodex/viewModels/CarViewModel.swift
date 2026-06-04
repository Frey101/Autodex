import Foundation
import Observation

@Observable
class CarViewModel {
    var cars: [Car] = []
    var isLoading = false
    var errorMessage: String? = nil
    

    // Recherche par MARQUE
    func fetchCars(searchQuery: String) async {
        let cleanQuery = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !cleanQuery.isEmpty else { return }
        
        let targetYear = 2025
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/\(cleanQuery)/modelyear/\(targetYear)?format=json"
        
        await performRequest(urlString: urlString, defaultYear: targetYear)
    }
    
    // Remplissage de l'écran d'accueil (Populaire)
    // Remplissage de l'écran d'accueil (Populaire / Découverte)
    // Remplissage de l'écran d'accueil (Mélange de plusieurs marques)
    func fetchTrendingCars() async {
        self.isLoading = true
        self.errorMessage = nil
        
        let targetYear = 2026
        // La liste des marques que tu veux mélanger
        let brandsToMix = ["bmw", "audi", "mercedes", "honda", "fiat", "nissan", "volkswagen","lamborghini", "porsche","toyota"]
        
        var allMixedCars: [Car] = []
        
        // On utilise un TaskGroup pour télécharger toutes les marques en parallèle (très rapide)
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
                        
                        // On associe l'année à chaque voiture
                        return decodedResponse.Results.map { car -> Car in
                            var updatedCar = car
                            updatedCar.year = targetYear
                            return updatedCar
                        }
                    } catch {
                        print("Erreur pour la marque \(brand) : \(error)")
                        return []
                    }
                }
            }
            
            // On récupère les résultats de chaque marque au fur et à mesure
            for await brandCars in group {
                allMixedCars.append(contentsOf: brandCars)
            }
        }
        
        // --- LE VRAI ALÉATOIRE ---
        // .shuffled() mélange complètement le tableau final (les BMW, Audi, Fiat, etc. seront toutes mélangées)
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
    
    // Méthode réseau
    private func performRequest(urlString: String, defaultYear: Int) async {
        self.isLoading = true
        self.errorMessage = nil
        
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            self.errorMessage = "Erreur : Recherche invalide."
            self.isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode != 200 {
                await MainActor.run {
                    self.errorMessage = "Erreur serveur (Code \(httpResponse.statusCode))."
                    self.isLoading = false
                }
                return
            }
            
            // Décodage de la structure globale NHTSAResponse
            let decodedResponse = try JSONDecoder().decode(NHTSAResponse.self, from: data)
            
            let finalCars = decodedResponse.Results.map { car -> Car in
                var updatedCar = car
                updatedCar.year = defaultYear
                return updatedCar
            }
            
            await MainActor.run {
                self.cars = finalCars
                self.isLoading = false
            }
            
        } catch {
            print("Erreur de décodage ou réseau : \(error)")
            await MainActor.run {
                self.errorMessage = "Aucun résultat ou erreur de connexion."
                self.isLoading = false
            }
        }
    }
}
