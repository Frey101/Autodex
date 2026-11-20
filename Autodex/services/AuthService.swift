//
//  AuthService.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import Foundation
import SwiftUI
import Observation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

/// Service central gérant l'authentification Firebase (Email/Mot de passe et Google/Gmail).
@Observable
@MainActor
public final class AuthService {
    public static let shared = AuthService()
    
    // MARK: - Propriétés Observables
    public var utilisateurCourant: UtilisateurAutodex? = nil
    public var estEnChargement: Bool = false
    public var messageErreur: String? = nil
    public var estConfigureFirebase: Bool = false
    
    public var estConnecte: Bool {
        utilisateurCourant != nil
    }
    
    // MARK: - Initialisation
    public init() {
        configurerFirebaseSiDisponible()
    }
    
    /// Initialise Firebase uniquement si le fichier GoogleService-Info.plist est présent dans l'application.
    public func configurerFirebaseSiDisponible() {
        #if canImport(FirebaseCore) && canImport(FirebaseAuth)
        if let cheminPlist = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            if FirebaseApp.app() == nil {
                if let options = FirebaseOptions(contentsOfFile: cheminPlist) {
                    FirebaseApp.configure(options: options)
                    self.estConfigureFirebase = true
                    print("✅ Firebase configuré avec succès via GoogleService-Info.plist")
                } else {
                    FirebaseApp.configure()
                    self.estConfigureFirebase = true
                    print("✅ Firebase configuré avec succès par défaut")
                }
            } else {
                self.estConfigureFirebase = true
            }
            
            // Écoute en temps réel de l'état d'authentification Firebase
            ecouterChangementsAuthentification()
        } else {
            self.estConfigureFirebase = false
            print("ℹ️ GoogleService-Info.plist non présent dans le bundle. Firebase est en attente de configuration.")
        }
        #else
        self.estConfigureFirebase = false
        print("ℹ️ SDK Firebase non compilé dans la cible actuelle.")
        #endif
    }
    
    // MARK: - Écoute des changements de session Firebase
    private func ecouterChangementsAuthentification() {
        #if canImport(FirebaseAuth)
        guard estConfigureFirebase else { return }
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            Task { @MainActor in
                if let user = user {
                    let provider = user.providerData.first?.providerID == "google.com" ? FournisseurAuth.google : FournisseurAuth.emailMotDePasse
                    self?.utilisateurCourant = UtilisateurAutodex(
                        id: user.uid,
                        email: user.email ?? "Utilisateur",
                        nomAffichage: user.displayName,
                        photoURL: user.photoURL,
                        fournisseur: provider
                    )
                } else {
                    self?.utilisateurCourant = nil
                }
            }
        }
        #endif
    }
    
    // MARK: - Connexion par Email et Mot de passe
    public func connexion(email: String, motDePasse: String) async throws {
        messageErreur = nil
        let emailPropre = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        try validerIdentifiants(email: emailPropre, motDePasse: motDePasse)
        
        guard estConfigureFirebase else {
            throw ErreurAuth.configurationManquante
        }
        
        estEnChargement = true
        defer { estEnChargement = false }
        
        #if canImport(FirebaseAuth)
        do {
            let resultat = try await Auth.auth().signIn(withEmail: emailPropre, password: motDePasse)
            let user = resultat.user
            self.utilisateurCourant = UtilisateurAutodex(
                id: user.uid,
                email: user.email ?? emailPropre,
                nomAffichage: user.displayName,
                photoURL: user.photoURL,
                fournisseur: .emailMotDePasse
            )
        } catch {
            let message = formaterErreur(error)
            self.messageErreur = message
            throw ErreurAuth.erreurPersonnalisee(message)
        }
        #else
        throw ErreurAuth.configurationManquante
        #endif
    }
    
    // MARK: - Inscription par Email et Mot de passe
    public func inscription(email: String, motDePasse: String, confirmationMotDePasse: String? = nil) async throws {
        messageErreur = nil
        let emailPropre = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        try validerIdentifiants(email: emailPropre, motDePasse: motDePasse)
        
        if let confirmation = confirmationMotDePasse, motDePasse != confirmation {
            let msg = "Les mots de passe saisis ne correspondent pas."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
        
        guard estConfigureFirebase else {
            throw ErreurAuth.configurationManquante
        }
        
        estEnChargement = true
        defer { estEnChargement = false }
        
        #if canImport(FirebaseAuth)
        do {
            let resultat = try await Auth.auth().createUser(withEmail: emailPropre, password: motDePasse)
            let user = resultat.user
            self.utilisateurCourant = UtilisateurAutodex(
                id: user.uid,
                email: user.email ?? emailPropre,
                nomAffichage: user.displayName,
                photoURL: user.photoURL,
                fournisseur: .emailMotDePasse
            )
        } catch {
            let message = formaterErreur(error)
            self.messageErreur = message
            throw ErreurAuth.erreurPersonnalisee(message)
        }
        #else
        throw ErreurAuth.configurationManquante
        #endif
    }
    
    // MARK: - Connexion via Google (Gmail)
    public func connexionGoogle() async throws {
        messageErreur = nil
        
        guard estConfigureFirebase else {
            throw ErreurAuth.configurationManquante
        }
        
        estEnChargement = true
        defer { estEnChargement = false }
        
        #if canImport(GoogleSignIn) && canImport(FirebaseAuth)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            let msg = "Impossible de présenter la fenêtre de connexion Google."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
        
        do {
            let resultatGID = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let userGID = resultatGID.user
            
            guard let idToken = userGID.idToken?.tokenString else {
                throw ErreurAuth.erreurPersonnalisee("Jeton d'identification Google manquant.")
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: userGID.accessToken.tokenString
            )
            
            let resultatAuth = try await Auth.auth().signIn(with: credential)
            let user = resultatAuth.user
            
            self.utilisateurCourant = UtilisateurAutodex(
                id: user.uid,
                email: user.email ?? userGID.profile?.email ?? "Google User",
                nomAffichage: user.displayName ?? userGID.profile?.name,
                photoURL: user.photoURL ?? userGID.profile?.imageURL(withDimension: 120),
                fournisseur: .google
            )
        } catch {
            let message = formaterErreur(error)
            self.messageErreur = message
            throw ErreurAuth.erreurPersonnalisee(message)
        }
        #else
        throw ErreurAuth.configurationManquante
        #endif
    }
    
    // MARK: - Réinitialisation du Mot de passe par Email
    public func reinitialiserMotDePasse(email: String) async throws {
        messageErreur = nil
        let emailPropre = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !emailPropre.isEmpty else {
            let msg = "Veuillez renseigner votre adresse email pour recevoir le lien de réinitialisation."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
        
        guard validerFormatEmail(emailPropre) else {
            let msg = "Veuillez saisir une adresse email valide."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
        
        guard estConfigureFirebase else {
            throw ErreurAuth.configurationManquante
        }
        
        estEnChargement = true
        defer { estEnChargement = false }
        
        #if canImport(FirebaseAuth)
        do {
            try await Auth.auth().sendPasswordReset(withEmail: emailPropre)
        } catch {
            let message = formaterErreur(error)
            self.messageErreur = message
            throw ErreurAuth.erreurPersonnalisee(message)
        }
        #else
        throw ErreurAuth.configurationManquante
        #endif
    }
    
    // MARK: - Déconnexion
    public func deconnexion() {
        #if canImport(FirebaseAuth)
        try? Auth.auth().signOut()
        #endif
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
        self.utilisateurCourant = nil
        self.messageErreur = nil
    }
    
    // MARK: - Validations Locales
    public func validerIdentifiants(email: String, motDePasse: String) throws {
        if email.isEmpty {
            let msg = "L'adresse email est requise."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
        
        if !validerFormatEmail(email) {
            let msg = "Le format de l'adresse email est invalide."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
        
        if motDePasse.isEmpty {
            let msg = "Le mot de passe est requis."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
        
        if motDePasse.count < 6 {
            let msg = "Le mot de passe doit comporter au moins 6 caractères (norme Firebase)."
            self.messageErreur = msg
            throw ErreurAuth.erreurPersonnalisee(msg)
        }
    }
    
    public func validerFormatEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    // MARK: - Traduction Française des Erreurs Firebase
    public func formaterErreur(_ error: Error) -> String {
        let nsError = error as NSError
        let description = error.localizedDescription
        
        // Codes d'erreurs standards Firebase Auth
        switch nsError.code {
        case 17008: // FIRAuthErrorCodeInvalidEmail
            return "L'adresse email saisie n'est pas valide."
        case 17011: // FIRAuthErrorCodeUserNotFound
            return "Aucun compte trouvé avec cette adresse email."
        case 17009: // FIRAuthErrorCodeWrongPassword
            return "Mot de passe incorrect. Veuillez réessayer."
        case 17007: // FIRAuthErrorCodeEmailAlreadyInUse
            return "Un compte existe déjà avec cette adresse email. Veuillez vous connecter."
        case 17026: // FIRAuthErrorCodeWeakPassword
            return "Le mot de passe est trop court (au moins 6 caractères requis)."
        case 17010: // FIRAuthErrorCodeTooManyRequests
            return "Trop de tentatives infructueuses. Veuillez patienter quelques instants."
        case 17020: // FIRAuthErrorCodeNetworkError
            return "Connexion réseau impossible. Vérifiez votre accès internet."
        default:
            if description.contains("email-already-in-use") {
                return "Un compte existe déjà avec cette adresse email."
            } else if description.contains("invalid-email") {
                return "Format d'adresse email invalide."
            } else if description.contains("wrong-password") || description.contains("INVALID_LOGIN_CREDENTIALS") {
                return "Email ou mot de passe incorrect."
            } else if description.contains("user-not-found") {
                return "Aucun compte ne correspond à cet email."
            } else if description.contains("weak-password") {
                return "Le mot de passe doit contenir au moins 6 caractères."
            }
            return description
        }
    }
}

// MARK: - Erreurs d'Authentification Spécifiques
public enum ErreurAuth: LocalizedError, Equatable {
    case configurationManquante
    case identifiantsInvalides
    case erreurPersonnalisee(String)
    
    public var errorDescription: String? {
        switch self {
        case .configurationManquante:
            return "Le fichier GoogleService-Info.plist est requis pour activer l'authentification Firebase."
        case .identifiantsInvalides:
            return "Identifiants d'authentification invalides."
        case .erreurPersonnalisee(let message):
            return message
        }
    }
}
