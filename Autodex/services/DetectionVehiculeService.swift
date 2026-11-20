//
//  DetectionVehiculeService.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import UIKit
import Vision

// MARK: - Résultat d'Analyse Vision
struct ResultatDetectionVehicule {
    let estUnVehicule: Bool
    let confianceMaximale: Float
    let etiquettePrincipale: String?
    let messageExplicatif: String
}

// MARK: - Service de Détection Automatique de Véhicules par IA Vision
final class DetectionVehiculeService {
    static let shared = DetectionVehiculeService()
    
    // Mots-clés identifiant un véhicule automobile dans la taxonomie officielle Apple Vision
    private let motsClesVehicules: Set<String> = [
        "car", "automobile", "motor vehicle", "passenger car",
        "sports car", "sportscar", "convertible", "coupe",
        "sedan", "limousine", "hatchback", "suv", "wagon",
        "station wagon", "minivan", "van", "pickup", "truck",
        "cab", "taxicab", "jeep", "racer", "race car",
        "land vehicle", "road vehicle", "vehicle", "supercar"
    ]
    
    // Seuil de confiance minimal pour valider la présence d'un véhicule
    private let seuilConfianceMinimal: Float = 0.12
    
    init() {}
    
    /// Analyse une image de manière asynchrone et détermine si elle contient un véhicule automobile
    func analyserPresenceVehicule(image: UIImage) async -> ResultatDetectionVehicule {
        guard let cgImage = recupererCGImage(depuis: image) else {
            return ResultatDetectionVehicule(
                estUnVehicule: false,
                confianceMaximale: 0.0,
                etiquettePrincipale: nil,
                messageExplicatif: "Format d'image incompatible pour l'analyse Vision."
            )
        }
        
        return analyserCGImage(cgImage)
    }
    
    /// Analyse directe et synchrone via VNClassifyImageRequest (sans completion handler ni risque de double reprise)
    func analyserCGImage(_ cgImage: CGImage) -> ResultatDetectionVehicule {
        let request = VNClassifyImageRequest()
        request.usesCPUOnly = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results as? [VNClassificationObservation], !observations.isEmpty else {
                return ResultatDetectionVehicule(
                    estUnVehicule: false,
                    confianceMaximale: 0.0,
                    etiquettePrincipale: nil,
                    messageExplicatif: "Aucun élément identifié sur l'image."
                )
            }
            
            // Recherche du meilleur match automobile
            var meilleurMatchVehicule: (etiquette: String, confiance: Float)? = nil
            
            for observation in observations {
                let identifiant = observation.identifier.lowercased()
                let confiance = observation.confidence
                
                if self.identifiantCorrespondAVehicule(identifiant) && confiance >= self.seuilConfianceMinimal {
                    if meilleurMatchVehicule == nil || confiance > meilleurMatchVehicule!.confiance {
                        meilleurMatchVehicule = (identifiant, confiance)
                    }
                }
            }
            
            if let match = meilleurMatchVehicule {
                return ResultatDetectionVehicule(
                    estUnVehicule: true,
                    confianceMaximale: match.confiance,
                    etiquettePrincipale: match.etiquette,
                    messageExplicatif: "Véhicule détecté : \(match.etiquette) (\(Int(match.confiance * 100))%)"
                )
            } else {
                let premier = observations.first
                return ResultatDetectionVehicule(
                    estUnVehicule: false,
                    confianceMaximale: premier?.confidence ?? 0.0,
                    etiquettePrincipale: premier?.identifier,
                    messageExplicatif: "Aucun véhicule automobile détecté sur cette photo."
                )
            }
        } catch {
            return ResultatDetectionVehicule(
                estUnVehicule: false,
                confianceMaximale: 0.0,
                etiquettePrincipale: nil,
                messageExplicatif: "Échec de traitement Vision : \(error.localizedDescription)"
            )
        }
    }
    
    /// Détermine si une étiquette Vision appartient au lexique automobile
    func identifiantCorrespondAVehicule(_ identifiant: String) -> Bool {
        let chaine = identifiant.lowercased()
        
        for motCle in motsClesVehicules {
            if chaine == motCle { return true }
            if chaine.contains("\(motCle) ") || chaine.contains(" \(motCle)") { return true }
            if chaine.contains("_\(motCle)") || chaine.contains("\(motCle)_") { return true }
            if chaine.contains("-\(motCle)") || chaine.contains("\(motCle)-") { return true }
        }
        return false
    }
    
    /// Extraction fiable du CGImage quel que soit le format source UIKit
    private func recupererCGImage(depuis image: UIImage) -> CGImage? {
        if let cg = image.cgImage {
            return cg
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let jpegData = renderer.jpegData(withCompressionQuality: 0.9) { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        return UIImage(data: jpegData)?.cgImage
    }
}
