import Foundation

// MARK: - Réponse de l'API NHTSA (conservée pour rétro-compatibilité)
struct NHTSAResponse: Codable {
    let Count: Int?
    let Message: String?
    let SearchCriteria: String?
    let Results: [Car]
}

// MARK: - Modèles de données du catalogue local complet
struct DetailVehiculeData: Codable, Identifiable {
    let id: Int
    let brand: String
    let model: String
    let production_year_start: Int?
    let production_year_end: Int?
    let body_styles: [String]?
    let fuel_types: [String]?
    let engines: [MoteurData]?
}

struct MoteurData: Codable {
    let name: String?
    let power_hp: Double?
    let fuel: String?
    let transmissions: [String]?
}

// MARK: - Modèle principal de véhicule pour l'interface
struct Car: Identifiable, Codable {
    var id: UUID = UUID()
    
    // Informations d'identification
    let Make_Name: String?
    let Model_Name: String?
    
    // Caractéristiques techniques et moteur
    var year: Int?
    let vehicleClass: String?
    let fuelType: String?
    let cylinders: Int?
    let displacement: Double?
    let transmission: String?
    let drive: String?
    let cityMpg: Int?
    let highwayMpg: Int?
    var horsepower: Int?
    var engineName: String?
    
    // Titres calculés pour les vues SwiftUI
    var displayName: String {
        return "\(Make_Name ?? "") \(Model_Name ?? "")"
    }
    
    var displaySubtitle: String {
        var elements: [String] = []
        if let year = year {
            elements.append("Modèle \(year)")
        }
        if let hp = horsepower {
            elements.append("\(hp) ch")
        } else if let vehicleClass = vehicleClass {
            elements.append(vehicleClass.capitalized)
        }
        return elements.isEmpty ? "Véhicule" : elements.joined(separator: " • ")
    }
    
    // Initialiseur manuel complet
    init(
        Make_Name: String?,
        Model_Name: String?,
        year: Int? = nil,
        vehicleClass: String? = nil,
        fuelType: String? = nil,
        cylinders: Int? = nil,
        displacement: Double? = nil,
        transmission: String? = nil,
        drive: String? = nil,
        cityMpg: Int? = nil,
        highwayMpg: Int? = nil,
        horsepower: Int? = nil,
        engineName: String? = nil
    ) {
        self.id = UUID()
        self.Make_Name = Make_Name
        self.Model_Name = Model_Name
        self.year = year
        self.vehicleClass = vehicleClass
        self.fuelType = fuelType
        self.cylinders = cylinders
        self.displacement = displacement
        self.transmission = transmission
        self.drive = drive
        self.cityMpg = cityMpg
        self.highwayMpg = highwayMpg
        self.horsepower = horsepower
        self.engineName = engineName
    }
    
    // Initialiseur depuis une fiche du dataset local
    init(fromDetail detail: DetailVehiculeData) {
        let premierMoteur = detail.engines?.first
        self.id = UUID()
        self.Make_Name = detail.brand
        self.Model_Name = detail.model
        self.year = detail.production_year_start
        self.vehicleClass = detail.body_styles?.first
        self.fuelType = premierMoteur?.fuel ?? detail.fuel_types?.first
        self.cylinders = nil
        self.displacement = nil
        self.transmission = premierMoteur?.transmissions?.first
        self.drive = nil
        self.cityMpg = nil
        self.highwayMpg = nil
        if let hp = premierMoteur?.power_hp {
            self.horsepower = Int(hp)
        } else {
            self.horsepower = nil
        }
        self.engineName = premierMoteur?.name
    }
    
    // Décodage Codable avec gestion des champs optionnels
    enum CodingKeys: String, CodingKey {
        case Make_Name
        case Model_Name
        case year
        case vehicleClass = "class"
        case fuelType = "fuel_type"
        case cylinders
        case displacement
        case transmission
        case drive
        case cityMpg = "city_mpg"
        case highwayMpg = "highway_mpg"
        case horsepower = "power_hp"
        case engineName = "engine_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.Make_Name = try container.decodeIfPresent(String.self, forKey: .Make_Name)
        self.Model_Name = try container.decodeIfPresent(String.self, forKey: .Model_Name)
        self.year = try container.decodeIfPresent(Int.self, forKey: .year)
        self.vehicleClass = try container.decodeIfPresent(String.self, forKey: .vehicleClass)
        self.fuelType = try container.decodeIfPresent(String.self, forKey: .fuelType)
        self.cylinders = try container.decodeIfPresent(Int.self, forKey: .cylinders)
        self.displacement = try container.decodeIfPresent(Double.self, forKey: .displacement)
        self.transmission = try container.decodeIfPresent(String.self, forKey: .transmission)
        self.drive = try container.decodeIfPresent(String.self, forKey: .drive)
        self.cityMpg = try container.decodeIfPresent(Int.self, forKey: .cityMpg)
        self.highwayMpg = try container.decodeIfPresent(Int.self, forKey: .highwayMpg)
        self.horsepower = try container.decodeIfPresent(Int.self, forKey: .horsepower)
        self.engineName = try container.decodeIfPresent(String.self, forKey: .engineName)
    }
}
