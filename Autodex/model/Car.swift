import Foundation

//Réponse de l'api NHTSA
struct NHTSAResponse: Codable{
    let Count : Int?
    let Message: String?
    let SearchCriteria: String?
    let Results: [Car]
}

struct Car: Identifiable, Codable {
    var id: UUID { UUID() } // Génère un ID unique pour SwiftUI
    
    // Champs de base (ex: API NHTSA)
    let Make_Name: String?
    let Model_Name: String?
    
    // Autres caractéristiques possibles (ex: API Ninjas Cars ou similaires)
    var year: Int?
    let vehicleClass: String?
    let fuelType: String?
    let cylinders: Int?
    let displacement: Double?
    let transmission: String?
    let drive: String?
    let cityMpg: Int?
    let highwayMpg: Int?
    
    // Variables calculées pour l'affichage
    var displayName: String {
        return "\(Make_Name ?? "") \(Model_Name ?? "")"
    }
    
    var displaySubtitle: String {
        if let year = year {
            return "Modèle \(year)"
        }
        return vehicleClass?.capitalized ?? "Véhicule"
    }
    
    // Mapping si les noms du JSON sont différents de tes variables Swift
    enum CodingKeys: String, CodingKey {
        case Make_Name
        case Model_Name
        case year
        case vehicleClass = "class" // Ex: si l'API renvoie "class", on le mappe sur "vehicleClass" car "class" est un mot réservé en Swift
        case fuelType = "fuel_type"
        case cylinders
        case displacement
        case transmission
        case drive
        case cityMpg = "city_mpg"
        case highwayMpg = "highway_mpg"
    }
}
