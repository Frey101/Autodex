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
        "pickup truck", "cab", "taxicab", "taxi", "jeep", "racer",
        "race car", "racing car", "land vehicle", "road vehicle",
        "vehicle", "supercar", "vehicle_toy", "wheel", "tire", "rim",
        "bumper", "grille", "headlight", "automotive", "motorcar",
        "roadster", "speedster", "hot rod", "muscle car", "classic car",
        "vintage car", "electric car", "electric vehicle", "hybrid car",
        "kart", "go-kart", "buggy", "auto", "chassis"
    ]
    
    // Seuil de confiance ajusté pour tenir compte de la dispersion sur 1 000+ classes Vision
    private let seuilConfianceMinimal: Float = 0.03
    
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
        
        // 1. Découpage par délimiteurs de taxonomie Vision (virgules, tirets, underscores, espaces, slashes)
        let morceaux = chaine.components(separatedBy: CharacterSet(charactersIn: ",_ -/"))
        for morceau in morceaux where !morceau.isEmpty {
            if motsClesVehicules.contains(morceau) {
                return true
            }
        }
        
        // 2. Recherche par inclusion exacte de sous-chaîne
        for motCle in motsClesVehicules {
            if chaine == motCle || chaine.contains(motCle) {
                return true
            }
        }
        return false
    }
    
    /// Extraction fiable du CGImage avec normalisation de l'orientation EXIF
    private func recupererCGImage(depuis image: UIImage) -> CGImage? {
        // Si l'orientation est déjà normale et que cgImage existe
        if image.imageOrientation == .up, let cg = image.cgImage {
            return cg
        }
        
        // Redessiner dans un contexte pour aplatir l'orientation EXIF de l'appareil photo/galerie
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let imageNormalisee = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        return imageNormalisee.cgImage ?? image.cgImage
    }
}
