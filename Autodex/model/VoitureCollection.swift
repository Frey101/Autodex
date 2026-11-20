//
//  VoitureCollection.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import Foundation
import SwiftData

@Model
final class VoitureCollection {
    @Attribute(.unique) var id: UUID
    var make: String
    var model: String
    var photoFileName: String
    var dateSpotting: Date
    
    init(make: String, model: String, photoFileName: String, dateSpotting: Date = Date()) {
        self.id = UUID()
        self.make = make.trimmingCharacters(in: .whitespacesAndNewlines)
        self.model = model.trimmingCharacters(in: .whitespacesAndNewlines)
        self.photoFileName = photoFileName
        self.dateSpotting = dateSpotting
    }
    
    // Titre d'affichage
    var displayName: String {
        "\(make) \(model)".trimmingCharacters(in: .whitespaces)
    }
    
    // Formatage de la date de capture
    var dateAffichee: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateSpotting)
    }
}
