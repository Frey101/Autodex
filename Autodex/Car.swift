import Foundation

struct Car: Codable, Identifiable {
    var id: UUID { UUID() }
    
    // L'API NHTSA utilise ces noms exacts avec des underscores
    let Make_Name: String?
    let Model_Name: String?
    
    // L'API ne renvoyant pas l'année directement dans l'objet,
    // on la stocke nous-mêmes pour l'affichage
    var year: Int? = 2026
    
    enum CodingKeys: String, CodingKey {
        case Make_Name
        case Model_Name
    }
    
    var displayName: String {
        let safeMake = Make_Name ?? "Inconnu"
        let safeModel = Model_Name ?? ""
        return "\(safeMake.capitalized) \(safeModel.capitalized)".trimmingCharacters(in: .whitespaces)
    }
    
    var displaySubtitle: String {
        let safeYear = year != nil ? String(year!) : "N/A"
        return "\(safeYear) - Spécification Standard"
    }
}

// L'enveloppe globale renvoyée par l'API NHTSA
struct NHTSAResponse: Codable {
    let Count: Int
    let Message: String
    let Results: [Car]
}
