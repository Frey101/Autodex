//
//  VoitureDuJourService.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import Foundation

// MARK: - Modèle de Données Léger pour le Widget et l'App Group
struct VoitureDuJourData: Codable, Identifiable, Equatable {
    var id: String { "\(make)_\(model)_\(year)" }
    let make: String
    let model: String
    let year: Int
    let horsepower: Int?
    let fuelType: String?
    let transmission: String?
    let vehicleClass: String?
    let anecdote: String
    let dateJour: String
    
    init(
        make: String,
        model: String,
        year: Int,
        horsepower: Int?,
        fuelType: String?,
        transmission: String?,
        vehicleClass: String?,
        anecdote: String,
        dateJour: String
    ) {
        self.make = make
        self.model = model
        self.year = year
        self.horsepower = horsepower
        self.fuelType = fuelType
        self.transmission = transmission
        self.vehicleClass = vehicleClass
        self.anecdote = anecdote
        self.dateJour = dateJour
    }
    
    var displayName: String {
        "\(make) \(model)"
    }
    
    var displaySubtitle: String {
        var elements: [String] = ["Modèle \(year)"]
        if let hp = horsepower {
            elements.append("\(hp) ch")
        }
        if let fuel = fuelType {
            elements.append(fuel)
        }
        return elements.joined(separator: " • ")
    }
    
    // Génération de l'URL Deep Link pour ouvrir directement l'application
    var deepLinkURL: URL {
        var components = URLComponents()
        components.scheme = "autodex"
        components.host = "car"
        components.queryItems = [
            URLQueryItem(name: "make", value: make),
            URLQueryItem(name: "model", value: model),
            URLQueryItem(name: "year", value: "\(year)")
        ]
        return components.url ?? URL(string: "autodex://car")!
    }
    
    // Conversion en instance Car complète pour navigation vers CarDetailView
    func toCar() -> Car {
        Car(
            Make_Name: make,
            Model_Name: model,
            year: year,
            vehicleClass: vehicleClass,
            fuelType: fuelType,
            transmission: transmission,
            horsepower: horsepower
        )
    }
}

// MARK: - Service de Gestion de la Voiture du Jour
final class VoitureDuJourService {
    static let shared = VoitureDuJourService()
    
    static let appGroupName = "group.com.dev.autodex"
    static let cleStockage = "voiture_du_jour_data"
    
    // Sélection emblématique de 31 véhicules légendaires (couvre tous les jours du mois)
    let catalogueEmblematique: [VoitureDuJourData] = [
        VoitureDuJourData(
            make: "Porsche",
            model: "911 GT3 RS",
            year: 2024,
            horsepower: 525,
            fuelType: "Essence",
            transmission: "Automatique (PDK)",
            vehicleClass: "Supercar",
            anecdote: "Aérodynamisme actif dérivé de la course avec système DRS.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Ferrari",
            model: "F40",
            year: 1987,
            horsepower: 478,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Supercar",
            anecdote: "Dernière création automobile supervisée par Enzo Ferrari.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Bugatti",
            model: "Chiron",
            year: 2016,
            horsepower: 1500,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Moteur W16 de 8 litres quadriturbo franchissant 420 km/h.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Alpine",
            model: "A110 R",
            year: 2023,
            horsepower: 300,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Coupé Sport",
            anecdote: "Châssis carbone ultra-léger pesant seulement 1 082 kg.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Lamborghini",
            model: "Revuelto",
            year: 2024,
            horsepower: 1015,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Premier V12 hybride rechargeable HPEV de Sant'Agata Bolognese.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "McLaren",
            model: "P1",
            year: 2013,
            horsepower: 916,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Pionnière de l'hybridation haute performance en Formule 1.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Renault",
            model: "5 Turbo",
            year: 1980,
            horsepower: 160,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Hatchback",
            anecdote: "Monstre sacré du Groupe B avec moteur turbo en position centrale.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "BMW",
            model: "M3 E30",
            year: 1986,
            horsepower: 200,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Berline Sportive",
            anecdote: "La reine absolue du championnat allemand DTM des années 80.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Audi",
            model: "RS6 Avant",
            year: 2023,
            horsepower: 630,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Break Sportif",
            anecdote: "V8 biturbo de 4.0L et légendaire transmission intégrale quattro.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Ferrari",
            model: "LaFerrari",
            year: 2013,
            horsepower: 963,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "V12 atmosphérique hurlant à 9 250 tr/min secondé par le HY-KERS.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Ford",
            model: "GT",
            year: 2017,
            horsepower: 656,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Supercar",
            anecdote: "Héritière directe de la victoire mythique aux 24 Heures du Mans 1966.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Porsche",
            model: "Carrera GT",
            year: 2004,
            horsepower: 612,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Supercar",
            anecdote: "V10 atmosphérique de course et embrayage carbone-céramique PCCC.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Mercedes-Benz",
            model: "AMG One",
            year: 2023,
            horsepower: 1063,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Véritable groupe propulseur champion du monde de Formule 1.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Peugeot",
            model: "205 GTI",
            year: 1984,
            horsepower: 130,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Hatchback",
            anecdote: "L'archétype légendaire des bombinettes sportives françaises.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Aston Martin",
            model: "Valkyrie",
            year: 2022,
            horsepower: 1160,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Conçue par le génie de la F1 Adrian Newey avec un V12 Cosworth à 11 100 tr/min.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Nissan",
            model: "GT-R Nismo",
            year: 2022,
            horsepower: 600,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Coupé Sport",
            anecdote: "Surnommée 'Godzilla' pour son efficacité chirurgicale sur piste.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Chevrolet",
            model: "Corvette Z06",
            year: 2023,
            horsepower: 670,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Supercar",
            anecdote: "Le V8 atmosphérique le plus puissant jamais produit en grande série.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Toyota",
            model: "Supra MK4",
            year: 1993,
            horsepower: 330,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Coupé Sport",
            anecdote: "Moteur 2JZ-GTE indestructible au cœur de la mythologie automobile.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Ferrari",
            model: "SF90 Stradale",
            year: 2020,
            horsepower: 1000,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Supercar",
            anecdote: "Trois moteurs électriques épaulant un V8 biturbo : 0 à 100 en 2,5 s.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Porsche",
            model: "918 Spyder",
            year: 2013,
            horsepower: 887,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Première voiture de série sous la barre des 7 minutes au Nürburgring.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Koenigsegg",
            model: "Jesko",
            year: 2023,
            horsepower: 1600,
            fuelType: "Flex-Fuel",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Transmission LST à 9 rapports passant instantanément n'importe quel rapport.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Renault",
            model: "Clio Williams",
            year: 1993,
            horsepower: 150,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Hatchback",
            anecdote: "Célèbres jantes Speedline dorées célébrant les titres Williams-Renault en F1.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "BMW",
            model: "M5 CS",
            year: 2021,
            horsepower: 635,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Berline Sportive",
            anecdote: "La berline M la plus puissante et allégée avec 4 sièges baquets carbone.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Audi",
            model: "R8 V10 Performance",
            year: 2021,
            horsepower: 620,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Supercar",
            anecdote: "Le chant envoûtant du dernier V10 atmosphérique à 8 700 tr/min.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Mercedes-Benz",
            model: "300 SL Gullwing",
            year: 1954,
            horsepower: 215,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Coupé Classique",
            anecdote: "Première injection directe de carburant et portes papillon révolutionnaires.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Lamborghini",
            model: "Miura P400",
            year: 1966,
            horsepower: 350,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Supercar",
            anecdote: "Pionnière absolue du concept moderne de supercar à moteur central arrière.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Alfa Romeo",
            model: "33 Stradale",
            year: 2024,
            horsepower: 620,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Supercar",
            anecdote: "Renaissance exclusive sculptée à la main limitée à 33 exemplaires numérotés.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Maserati",
            model: "MC20",
            year: 2022,
            horsepower: 630,
            fuelType: "Essence",
            transmission: "Automatique",
            vehicleClass: "Supercar",
            anecdote: "Moteur V6 Nettuno breveté doté de la préchambre de combustion de Formule 1.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Lancia",
            model: "Delta HF Integrale",
            year: 1991,
            horsepower: 210,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Hatchback",
            anecdote: "Record inégalé de 6 titres mondiaux des constructeurs consécutifs en WRC.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Honda",
            model: "NSX",
            year: 1990,
            horsepower: 274,
            fuelType: "Essence",
            transmission: "Manuelle",
            vehicleClass: "Supercar",
            anecdote: "Mise au point dynamique peaufinée à Suzuka par la légende Ayrton Senna.",
            dateJour: ""
        ),
        VoitureDuJourData(
            make: "Bugatti",
            model: "Tourbillon",
            year: 2026,
            horsepower: 1800,
            fuelType: "Hybride",
            transmission: "Automatique",
            vehicleClass: "Hypercar",
            anecdote: "Nouveau V16 atmosphérique Cosworth associé à une instrumentation horlogère suisse.",
            dateJour: ""
        )
    ]
    
    init() {}
    
    // MARK: - Algorithme Déterministe Quotidien
    func indexPourDate(_ date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        var cal = calendar
        cal.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
        
        // Date de référence : 1er Janvier 2026 à 00:00:00
        var composantsRef = DateComponents()
        composantsRef.year = 2026
        composantsRef.month = 1
        composantsRef.day = 1
        composantsRef.hour = 0
        composantsRef.minute = 0
        composantsRef.second = 0
        
        let dateRef = cal.date(from: composantsRef) ?? date
        let composantsDiff = cal.dateComponents([.day], from: dateRef, to: date)
        let diffJours = composantsDiff.day ?? 0
        
        let poolCount = max(catalogueEmblematique.count, 1)
        let index = abs(diffJours) % poolCount
        return index
    }
    
    func formaterDateJour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
        return formatter.string(from: date)
    }
    
    func formaterDateAffichee(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Récupère la voiture du jour déterministe pour une date donnée
    func obtenirVoitureDuJour(pour date: Date = Date()) -> VoitureDuJourData {
        let index = indexPourDate(date)
        let modele = catalogueEmblematique[index]
        let dateString = formaterDateJour(date)
        
        return VoitureDuJourData(
            make: modele.make,
            model: modele.model,
            year: modele.year,
            horsepower: modele.horsepower,
            fuelType: modele.fuelType,
            transmission: modele.transmission,
            vehicleClass: modele.vehicleClass,
            anecdote: modele.anecdote,
            dateJour: dateString
        )
    }
    
    // Calcule la date du prochain renouvellement (minuit le lendemain)
    func prochaineDateRafraichissement(depuis date: Date = Date()) -> Date {
        let calendar = Calendar.current
        guard let demain = calendar.date(byAdding: .day, value: 1, to: date) else {
            return date.addingTimeInterval(86400)
        }
        return calendar.startOfDay(for: demain)
    }
    
    // MARK: - Synchronisation App Group & UserDefaults
    func sauvegarderDansAppGroup(_ voiture: VoitureDuJourData) {
        let defaults = UserDefaults(suiteName: Self.appGroupName) ?? UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(voiture) {
            defaults.set(encoded, forKey: Self.cleStockage)
        }
    }
    
    func chargerDepuisAppGroup() -> VoitureDuJourData? {
        let defaults = UserDefaults(suiteName: Self.appGroupName) ?? UserDefaults.standard
        guard let data = defaults.data(forKey: Self.cleStockage),
              let voiture = try? JSONDecoder().decode(VoitureDuJourData.self, from: data) else {
            return nil
        }
        return voiture
    }
    
    @discardableResult
    func synchroniser(date: Date = Date()) -> VoitureDuJourData {
        let voiture = obtenirVoitureDuJour(pour: date)
        sauvegarderDansAppGroup(voiture)
        return voiture
    }
    
    // MARK: - Parsing des URLs de Deep Link (autodex://car?make=...&model=...&year=...)
    func analyserUrlDeepLink(_ url: URL) -> (make: String, model: String, year: Int?)? {
        guard url.scheme?.lowercased() == "autodex" else { return nil }
        guard url.host?.lowercased() == "car" else { return nil }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        let items = components.queryItems ?? []
        
        let make = items.first(where: { $0.name == "make" })?.value
        let model = items.first(where: { $0.name == "model" })?.value
        let yearString = items.first(where: { $0.name == "year" })?.value
        let year = yearString != nil ? Int(yearString!) : nil
        
        guard let makeValide = make, !makeValide.isEmpty,
              let modelValide = model, !modelValide.isEmpty else {
            return nil
        }
        
        return (makeValide, modelValide, year)
    }
}
