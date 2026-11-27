//
//  DetectionVehiculeTests.swift
//  AutodexTests
//
//  Created by Tom Tas on 20/11/2026.
//

import XCTest
import UIKit
import Vision
@testable import Autodex

final class DetectionVehiculeTests: XCTestCase {
    
    var service: DetectionVehiculeService!
    
    override func setUp() {
        super.setUp()
        service = DetectionVehiculeService.shared
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - 1. Tests des Mots-Clés et de la Taxonomie Vision
    func testIdentifiantsAutomobilesValides() {
        let identifiantsValides = [
            "car",
            "sports car",
            "land_vehicle",
            "motor vehicle",
            "convertible",
            "coupe",
            "sedan",
            "passenger car",
            "suv",
            "minivan",
            "truck",
            "limousine",
            "supercar",
            "race car"
        ]
        
        for id in identifiantsValides {
            XCTAssertTrue(
                service.identifiantCorrespondAVehicule(id),
                "L'identifiant '\(id)' doit être reconnu comme un véhicule automobile."
            )
        }
    }
    
    func testIdentifiantsNonAutomobilesRefuses() {
        let identifiantsInvalides = [
            "cat",
            "dog",
            "cup",
            "coffee",
            "building",
            "tree",
            "flower",
            "laptop",
            "chair",
            "pizza",
            "person",
            "table"
        ]
        
        for id in identifiantsInvalides {
            XCTAssertFalse(
                service.identifiantCorrespondAVehicule(id),
                "L'identifiant '\(id)' ne doit PAS être considéré comme un véhicule."
            )
        }
    }
    
    // MARK: - 2. Tests d'Analyse d'Images Réelles et Rejets
    func testImageMonochromeSansVoitureEstRefusee() async {
        // Image rouge unie sans aucun véhicule
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        let imageRouge = renderer.image { context in
            UIColor.systemRed.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        
        let resultat = await service.analyserPresenceVehicule(image: imageRouge)
        
        XCTAssertFalse(
            resultat.estUnVehicule,
            "Une image rouge unie sans véhicule doit obligatoirement être refusée."
        )
    }
    
    func testDessinObjetNonAutomobileEstRefuse() async {
        // Dessin d'un carré bleu et d'un cercle vert (aucun véhicule)
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        let imageObjet = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            UIColor.systemGreen.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 100, y: 100, width: 200, height: 200))
        }
        
        let resultat = await service.analyserPresenceVehicule(image: imageObjet)
        
        XCTAssertFalse(
            resultat.estUnVehicule,
            "Une illustration non automobile doit être refusée."
        )
    }
    
    func testPhotoReelleVoitureEstAcceptee() async throws {
        // Sur un runner CI virtualisé sans Neural Engine, VNClassifyImageRequest peut ne pas classifier l'image.
        // Le workflow passe TEST_RUNNER_CI=1, exposé ici en "CI" par xcodebuild.
        try XCTSkipIf(
            ProcessInfo.processInfo.environment["CI"] != nil,
            "Classification Vision non fiable sur runner CI virtualisé"
        )
        // Chargement dynamique du visuel voiture depuis le projet
        let currentFileURL = URL(fileURLWithPath: #file)
        let projectRoot = currentFileURL.deletingLastPathComponent().deletingLastPathComponent()
        let cheminVoiture = projectRoot.appendingPathComponent("Autodex/Assets.xcassets/images/voiture.png").path
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: cheminVoiture)),
           let image = UIImage(data: data) {
            let resultat = await service.analyserPresenceVehicule(image: image)
            XCTAssertTrue(resultat.estUnVehicule, "Une image de voiture doit être acceptée par le service Vision.")
        }
    }
    
    func testImageInvalideFormatZeroGereeSansCrash() async {
        // Image minuscule 1x1
        let size = CGSize(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: size)
        let imageMinuscule = renderer.image { _ in }
        
        let resultat = await service.analyserPresenceVehicule(image: imageMinuscule)
        // Ne doit pas crasher et doit refuser
        XCTAssertFalse(resultat.estUnVehicule)
    }
}
