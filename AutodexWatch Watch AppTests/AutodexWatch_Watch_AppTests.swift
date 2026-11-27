//
//  AutodexWatch_Watch_AppTests.swift
//  AutodexWatch Watch AppTests
//
//  Created by Tom Tas on 26/11/2026.
//

import Testing
@testable import AutodexWatch_Watch_App

/// Suite de tests unitaires pour l'application compagnon Apple Watch.
struct AutodexWatch_Watch_AppTests {

    /// Vérifie que toutes les catégories d'énergie Watch sont présentes.
    @Test func testCategoriesEnergieWatch() async throws {
        let energies = WatchEnergie.allCases
        #expect(energies.count == 4)
        #expect(energies.contains(.tous))
        #expect(energies.contains(.hybride))
        #expect(energies.contains(.electrique))
        #expect(energies.contains(.essence))
    }

    /// Vérifie l'initialisation et l'égalité d'un modèle WatchCar.
    @Test func testModeleWatchCar() async throws {
        let f80 = WatchCar(
            id: "f80",
            marque: "Ferrari",
            modele: "F80",
            puissance: 1200,
            carburant: .hybride,
            annee: 2025,
            zeroACent: "2.15 s",
            transmission: "AWD"
        )
        #expect(f80.id == "f80")
        #expect(f80.puissance == 1200)
        #expect(f80.carburant == .hybride)
    }
}
