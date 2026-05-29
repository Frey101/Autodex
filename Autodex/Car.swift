import Foundation

struct Car: Codable, Identifiable {
    // On génère un ID unique car l'API Ninjas n'en fournit pas, et SwiftUI en a besoin pour la liste
    var id: UUID { UUID() }
    
    let make: String
    let model: String
    let year: Int
    let fuel_type: String
    
    // Propriété pour le titre
    var displayName: String {
        return "\(make.capitalized) \(model.capitalized)"
    }
    
    // Propriété pour le sous-titre avec traduction du carburant
    var displaySubtitle: String {
        let fuelFR: String
        switch fuel_type {
        case "gas": fuelFR = "Essence"
        case "diesel": fuelFR = "Diesel"
        case "electricity": fuelFR = "Électrique"
        default: fuelFR = fuel_type.capitalized
        }
        return "\(year) - \(fuelFR)"
    }
}
