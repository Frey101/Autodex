//
//  AutodexWatch_Watch_AppUITests.swift
//  AutodexWatch Watch AppUITests
//
//  Created by Tom Tas on 26/11/2026.
//

import XCTest

/// Suite de tests d'interface (UI) pour l'application compagnon Apple Watch.
final class AutodexWatch_Watch_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Vérifie que l'application Watch se lance correctement et affiche l'écran principal.
    @MainActor
    func testLancementWatchApp() throws {
        let app = XCUIApplication()
        app.launch()

        // Vérifier que l'interface Watch est bien chargée à l'écran
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "L'application Watch doit être au premier plan.")
    }
}
