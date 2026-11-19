//
//  BrandLogoService.swift
//  Autodex
//
//  Service asynchrone de récupération et mise en cache des logos
//  des constructeurs automobiles via le dataset open-source et Wikipédia.
//

import Foundation
import UIKit

final class BrandLogoService: Sendable {
    static let shared = BrandLogoService()
    
    // Base CDN gratuite hébergeant les logos officiels en haute résolution transparente (PNG)
    private let baseCdnUrl = "https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/"
    
    // Correspondances spécifiques pour normaliser les noms de marques
    private let correspondancesMarques: [String: String] = [
        "mercedes": "mercedes-benz",
        "vw": "volkswagen",
        "chevy": "chevrolet",
        "infiniti": "infiniti",
        "land rover": "land-rover",
        "alfa romeo": "alfa-romeo",
        "aston martin": "aston-martin",
        "rolls royce": "rolls-royce"
    ]
    
    private init() {}
    
    // Génère l'URL directe du logo pour une marque donnée
    func urlLogo(pour marque: String) -> URL? {
        let marqueNettoyee = marque.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !marqueNettoyee.isEmpty else { return nil }
        
        // Vérification des correspondances spécifiques ou remplacement des espaces
        let slug = correspondancesMarques[marqueNettoyee] ?? marqueNettoyee.replacingOccurrences(of: " ", with: "-")
        
        let urlComplete = "\(baseCdnUrl)\(slug).png"
        return URL(string: urlComplete)
    }
}
