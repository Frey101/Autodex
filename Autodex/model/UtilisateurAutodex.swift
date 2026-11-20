//
//  UtilisateurAutodex.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import Foundation

/// Modèle représentant un utilisateur authentifié dans AutoDex.
public struct UtilisateurAutodex: Identifiable, Codable, Equatable {
    public let id: String
    public let email: String
    public let nomAffichage: String?
    public let photoURL: URL?
    public let fournisseur: FournisseurAuth
    public let dateConnexion: Date
    
    public init(
        id: String,
        email: String,
        nomAffichage: String? = nil,
        photoURL: URL? = nil,
        fournisseur: FournisseurAuth = .emailMotDePasse,
        dateConnexion: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.nomAffichage = nomAffichage
        self.photoURL = photoURL
        self.fournisseur = fournisseur
        self.dateConnexion = dateConnexion
    }
    
    /// Nom d'affichage prioritaire ou début de l'adresse email
    public var nomOuEmail: String {
        if let nom = nomAffichage, !nom.trimmingCharacters(in: .whitespaces).isEmpty {
            return nom
        }
        return email.components(separatedBy: "@").first?.capitalized ?? email
    }
    
    /// Initiales pour l'avatar par défaut
    public var initiales: String {
        let nom = nomOuEmail
        let parties = nom.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        if parties.count >= 2, let prem = parties.first?.first, let sec = parties.last?.first {
            return "\(prem)\(sec)".uppercased()
        }
        return String(nom.prefix(2)).uppercased()
    }
}

/// Type de fournisseur d'authentification utilisé
public enum FournisseurAuth: String, Codable, Equatable {
    case emailMotDePasse = "email"
    case google = "google"
    
    public var libelle: String {
        switch self {
        case .emailMotDePasse: return "Email"
        case .google: return "Google (Gmail)"
        }
    }
    
    public var iconeSysteme: String {
        switch self {
        case .emailMotDePasse: return "envelope.fill"
        case .google: return "globe"
        }
    }
}
