//
//  CollectionPhotoService.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import UIKit

final class CollectionPhotoService {
    static let shared = CollectionPhotoService()
    
    private let nomDossier = "PhotosCollection"
    
    private var dossierPhotosURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dossier = documents.appendingPathComponent(nomDossier, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dossier.path) {
            try? FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
        }
        return dossier
    }
    
    init() {}
    
    // MARK: - Sauvegarde d'une Image JPEG sur le Disque Local
    func sauvegarderPhoto(_ image: UIImage) -> String? {
        let nomFichier = "spot_\(UUID().uuidString).jpg"
        let destinationURL = dossierPhotosURL.appendingPathComponent(nomFichier)
        
        // Compression JPEG optimisée pour la fluidité et l'espace disque
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            return nil
        }
        
        do {
            try data.write(to: destinationURL, options: .atomic)
            return nomFichier
        } catch {
            print("Erreur de sauvegarde de la photo de collection : \(error)")
            return nil
        }
    }
    
    // MARK: - Chargement d'une Image depuis le Disque Local
    func chargerPhoto(nomFichier: String) -> UIImage? {
        let fileURL = dossierPhotosURL.appendingPathComponent(nomFichier)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    // MARK: - Suppression d'une Photo sur le Disque
    func supprimerPhoto(nomFichier: String) {
        let fileURL = dossierPhotosURL.appendingPathComponent(nomFichier)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // MARK: - Générateur d'Image de Démonstration (Simulateur / Tests)
    func genererImageDemo(marque: String, modele: String) -> UIImage {
        let size = CGSize(width: 800, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Fond dégradé dynamique
            let colors = [
                UIColor(red: 24/255, green: 32/255, blue: 54/255, alpha: 1.0).cgColor,
                UIColor(red: 45/255, green: 55/255, blue: 85/255, alpha: 1.0).cgColor
            ]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Dessin d'une silhouette de bolide
            let config = UIImage.SymbolConfiguration(pointSize: 120, weight: .bold)
            if let carIcon = UIImage(systemName: "car.side.fill", withConfiguration: config)?.withTintColor(.white.withAlphaComponent(0.85), renderingMode: .alwaysOriginal) {
                let iconRect = CGRect(x: (size.width - 240) / 2, y: 120, width: 240, height: 140)
                carIcon.draw(in: iconRect)
            }
            
            // Texte Titre
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            let attrsTitre: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 34, weight: .heavy),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ]
            let texteTitre = "\(marque) \(modele)"
            let rectTitre = CGRect(x: 20, y: 310, width: size.width - 40, height: 50)
            texteTitre.draw(in: rectTitre, withAttributes: attrsTitre)
            
            // Badge AutoDex Spotting
            let attrsBadge: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor(red: 120/255, green: 210/255, blue: 255/255, alpha: 1.0),
                .paragraphStyle: paragraph
            ]
            let texteBadge = "⚡ AutoDex Car Spotting ⚡"
            let rectBadge = CGRect(x: 20, y: 375, width: size.width - 40, height: 35)
            texteBadge.draw(in: rectBadge, withAttributes: attrsBadge)
        }
    }
}
