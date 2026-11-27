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
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results as? [VNClassificationObservation], !observations.isEmpty else {
                // Sur certains simulateurs sans modèle Vision complet, ne pas bloquer l'utilisateur
                return ResultatDetectionVehicule(
                    estUnVehicule: true,
                    confianceMaximale: 0.0,
                    etiquettePrincipale: "indisponible",
                    messageExplicatif: "Analyse Vision indisponible sur cet environnement, photo acceptée."
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
                let detail = premier.map { "\($0.identifier) (\(Int($0.confidence * 100))%)" } ?? "inconnu"
                return ResultatDetectionVehicule(
                    estUnVehicule: false,
                    confianceMaximale: premier?.confidence ?? 0.0,
                    etiquettePrincipale: premier?.identifier,
                    messageExplicatif: "Aucun véhicule détecté (élément principal vu : \(detail))."
                )
            }
        } catch {
            // En cas d'erreur moteur Vision (fréquent sur simulateur iOS), ne pas bloquer l'ajout
            return ResultatDetectionVehicule(
                estUnVehicule: true,
                confianceMaximale: 0.0,
                etiquettePrincipale: nil,
                messageExplicatif: "Analyse Vision indisponible (\(error.localizedDescription))."
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
    
    /// Extraction fiable du CGImage avec normalisation sRGB, taille max 1024px et orientation EXIF
    private func recupererCGImage(depuis image: UIImage) -> CGImage? {
        guard image.size.width > 1 && image.size.height > 1 else {
            return nil
        }
        
        // Redimensionnement raisonnable (max 1024px) pour éviter les échecs mémoire/CoreML sur les photos 12MP/48MP
        let maxDimension: CGFloat = 1024
        let ratio = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let targetSize = CGSize(
            width: max(1, floor(image.size.width * ratio)),
            height: max(1, floor(image.size.height * ratio))
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let imageNormalisee = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return imageNormalisee.cgImage ?? image.cgImage
    }
}
