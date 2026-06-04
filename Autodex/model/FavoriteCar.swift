//
//  FavoriteCar.swift
//  Autodex
//
//  Created by iutsd-mmi on 01/06/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteCar {
    @Attribute(.unique) var id: String // Combinaison unique (ex: "bmw-m3")
    var make: String
    var model: String
    var year: Int
    var timestamp: Date

    init(make: String, model: String, year: Int) {
        self.id = "\(make.lowercased())-\(model.lowercased())"
        self.make = make
        self.model = model
        self.year = year
        self.timestamp = Date()
    }
    
    // Affichage (toString)
    var displayName: String {
        return "\(make.capitalized) \(model.capitalized)".trimmingCharacters(in: .whitespaces)
    }
    
    var displaySubtitle: String {
        return "\(year) - Spécification Standard"
    }
}
