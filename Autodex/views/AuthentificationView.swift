//
//  AuthentificationView.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import SwiftUI

/// Mode d'affichage du formulaire d'authentification
public enum ModeAuthentification: String, CaseIterable, Identifiable {
    case connexion = "Connexion"
    case inscription = "Créer un compte"
    
    public var id: String { rawValue }
}

/// Vue principale d'authentification (Connexion, Inscription et Connexion Google).
public struct AuthentificationView: View {
    @State private var authService = AuthService.shared
    
    @State private var modeActuel: ModeAuthentification = .connexion
    @State private var email: String = ""
    @State private var motDePasse: String = ""
    @State private var confirmationMotDePasse: String = ""
    @State private var motDePasseVisible: Bool = false
    
    // États pour le mot de passe oublié
    @State private var afficheReinitialisation: Bool = false
    @State private var emailReinitialisation: String = ""
    @State private var messageSucces: String? = nil
    
    // Guide d'installation Firebase
    @State private var afficheGuideFirebase: Bool = false
    
    // Thème visuel AutoDex
    private let vertAutodex = Color(red: 131/255, green: 170/255, blue: 131/255)
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - En-tête AutoDex
                    enTeteBranding
                        .padding(.top, 20)
                    
                    // MARK: - Alerte de configuration si GoogleService-Info.plist est manquant
                    if !authService.estConfigureFirebase {
                        banniereConfigurationRequise
                    }
                    
                    // MARK: - Sélecteur de mode (Connexion / Créer un compte)
                    selecteurMode
                    
                    // MARK: - Formulaire de saisie
                    champsFormulaire
                    
                    // MARK: - Message d'erreur
                    if let erreur = authService.messageErreur {
                        banniereErreur(message: erreur)
                    }
                    
                    // MARK: - Message de succès
                    if let succes = messageSucces {
                        banniereSucces(message: succes)
                    }
                    
                    // MARK: - Bouton d'action principal
                    boutonActionPrincipal
                    
                    // MARK: - Mot de passe oublié (uniquement en mode connexion)
                    if modeActuel == .connexion {
                        Button {
                            emailReinitialisation = email
                            afficheReinitialisation = true
                        } label: {
                            Text("Mot de passe oublié ?")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(vertAutodex)
                        }
                        .padding(.top, 4)
                    }
                    
                    // MARK: - Séparateur
                    HStack(spacing: 14) {
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                        Text("ou continuer avec")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // MARK: - Bouton Google (Gmail)
                    boutonGoogle
                    
                    Spacer(minLength: 20)
                    
                    // MARK: - Mention légale & Sécurité
                    VStack(spacing: 4) {
                        Text("AutoDex • Authentification Firebase 100% Gratuite")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Vos identifiants sont sécurisés par le SDK Firebase.")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $afficheGuideFirebase) {
                GuideConfigurationFirebaseView()
            }
            .alert("Réinitialisation du mot de passe", isPresented: $afficheReinitialisation) {
                TextField("Votre adresse email", text: $emailReinitialisation)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                Button("Annuler", role: .cancel) {}
                Button("Envoyer l'email") {
                    declencherReinitialisation()
                }
            } message: {
                Text("Saisissez votre adresse email pour recevoir un lien officiel Firebase de réinitialisation.")
            }
        }
    }
    
    // MARK: - Sous-vues
    
    private var enTeteBranding: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(vertAutodex.opacity(0.18))
                    .frame(width: 80, height: 80)
                Image(systemName: "car.side.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(vertAutodex)
            }
            .shadow(color: vertAutodex.opacity(0.25), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 4) {
                Text("AutoDex")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Le Pokédex Automobile")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var banniereConfigurationRequise: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Configuration Firebase en attente")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text("Déposez GoogleService-Info.plist pour activer la connexion directe.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    afficheGuideFirebase = true
                } label: {
                    Text("Guide")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.10))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var selecteurMode: some View {
        Picker("Mode", selection: $modeActuel) {
            ForEach(ModeAuthentification.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 4)
    }
    
    private var champsFormulaire: some View {
        VStack(spacing: 14) {
            // Champ Email
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                TextField("Adresse e-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            
            // Champ Mot de passe
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                if motDePasseVisible {
                    TextField("Mot de passe (min. 6 caractères)", text: $motDePasse)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    SecureField("Mot de passe (min. 6 caractères)", text: $motDePasse)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                Button {
                    motDePasseVisible.toggle()
                } label: {
                    Image(systemName: motDePasseVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            
            // Confirmation du mot de passe (si inscription)
            if modeActuel == .inscription {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    SecureField("Confirmer le mot de passe", text: $confirmationMotDePasse)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var boutonActionPrincipal: some View {
        Button {
            executerAction()
        } label: {
            HStack(spacing: 10) {
                if authService.estEnChargement {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: modeActuel == .connexion ? "arrow.right.circle.fill" : "person.badge.plus")
                        .font(.headline)
                    Text(modeActuel == .connexion ? "Se connecter" : "Créer mon compte")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(vertAutodex)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(color: vertAutodex.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(authService.estEnChargement)
    }
    
    private var boutonGoogle: some View {
        Button {
            Task {
                do {
                    try await authService.connexionGoogle()
                } catch {
                    // L'erreur est gérée dans AuthService
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("Continuer avec Google (Gmail)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.separator), lineWidth: 1)
            )
        }
        .disabled(authService.estEnChargement)
    }
    
    private func banniereErreur(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.footnote)
                .foregroundColor(.red)
            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func banniereSucces(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vertAutodex)
            Text(message)
                .font(.footnote)
                .foregroundColor(vertAutodex)
            Spacer()
        }
        .padding(12)
        .background(vertAutodex.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - Actions Métier
    private func executerAction() {
        messageSucces = nil
        Task {
            do {
                if modeActuel == .connexion {
                    try await authService.connexion(email: email, motDePasse: motDePasse)
                } else {
                    try await authService.inscription(
                        email: email,
                        motDePasse: motDePasse,
                        confirmationMotDePasse: confirmationMotDePasse
                    )
                }
            } catch {
                // Erreur propagée et affichée dans la bannière
            }
        }
    }
    
    private func declencherReinitialisation() {
        messageSucces = nil
        Task {
            do {
                try await authService.reinitialiserMotDePasse(email: emailReinitialisation)
                messageSucces = "Un email de réinitialisation a été envoyé à \(emailReinitialisation)."
            } catch {
                // Erreur affichée
            }
        }
    }
}

// MARK: - Guide Pédagogique de Configuration Firebase
struct GuideConfigurationFirebaseView: View {
    @Environment(\.dismiss) private var dismiss
    private let vertAutodex = Color(red: 131/255, green: 170/255, blue: 131/255)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Comment configurer Firebase pour AutoDex ?")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("L'authentification utilise le SDK officiel Firebase (100% gratuit, sans compte Apple payant). Suivez ces 4 étapes simples :")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        etapeCarte(
                            numero: "1",
                            titre: "Créer un projet Firebase",
                            description: "Rendez-vous sur console.firebase.google.com et créez un projet (Formule Spark gratuite)."
                        )
                        
                        etapeCarte(
                            numero: "2",
                            titre: "Ajouter une application iOS",
                            description: "Indiquez l'ID de bundle exact : com.iutstdie.autodex."
                        )
                        
                        etapeCarte(
                            numero: "3",
                            titre: "Télécharger GoogleService-Info.plist",
                            description: "Téléchargez le fichier de configuration et glissez-le dans le dossier Autodex/ du projet."
                        )
                        
                        etapeCarte(
                            numero: "4",
                            titre: "Activer les Fournisseurs",
                            description: "Dans Firebase Console > Authentication > Sign-in method, activez 'Adresse e-mail/Mot de passe' et 'Google'."
                        )
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .navigationTitle("Configuration Firebase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func etapeCarte(numero: String, titre: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(vertAutodex)
                    .frame(width: 32, height: 32)
                Text(numero)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(titre)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
