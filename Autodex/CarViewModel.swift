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
    func fetchTrendingCars() async {
        let targetYear = 2026
        // On affiche par exemple les modèles BMW de 2026 par défaut
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/bmw/modelyear/\(targetYear)?format=json"
        
        await performRequest(urlString: urlString, defaultYear: targetYear)
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
