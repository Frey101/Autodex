//
//  AutodexApp.swift
//  Autodex
//
//  Created by Alyssia Frey on 29/05/2026.
//

import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

// MARK: - Initialisation de Firebase via AppDelegate (Recommandation officielle Firebase)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ FirebaseApp initialisé avec succès depuis AppDelegate")
        }
        #endif
        return true
    }
    
    // Gestion du retour d'authentification Google / OAuth
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        #if canImport(GoogleSignIn)
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        #endif
        return false
    }
}

@main
struct AutodexApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authService = AuthService.shared

    init() {
        // Configuration du cache réseau d'images (50 Mo RAM, 150 Mo disque)
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 150 * 1024 * 1024,
            diskPath: "autodex_images_cache"
        )
        // Synchronisation de la Voiture du Jour dans l'App Group
        VoitureDuJourService.shared.synchroniser()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("-UITestBypassAuth") || authService.estConnecte {
                    Navigationview()
                } else {
                    AuthentificationView()
                }
                #else
                if authService.estConnecte {
                    Navigationview()
                } else {
                    AuthentificationView()
                }
                #endif
            }
            .animation(.easeInOut(duration: 0.3), value: authService.estConnecte)
            .onOpenURL { url in
                #if canImport(GoogleSignIn)
                _ = GIDSignIn.sharedInstance.handle(url)
                #endif
            }
        }
        .modelContainer(for: [FavoriteCar.self, VoitureCollection.self])
    }
}
