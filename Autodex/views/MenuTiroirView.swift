//
//  MenuTiroirView.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import SwiftUI
import SwiftData

// MARK: - Définition des Sections de l'Application
enum SectionNavigation: String, CaseIterable, Identifiable {
    case accueil = "Accueil"
    case collection = "Ma Collection"
    case duel = "Mode Duel"
    case quiz = "Pokédex Quiz"
    case decouverte = "Découverte"
    case favoris = "Favoris"
    case aPropos = "À Propos"
    
    var id: String { rawValue }
    
    var titreComplet: String {
        switch self {
        case .accueil: return "Accueil & Catalogue"
        case .collection: return "Ma Collection"
        case .duel: return "Mode Duel Face-à-Face"
        case .quiz: return "Pokédex Quiz"
        case .decouverte: return "Découverte Aléatoire"
        case .favoris: return "Mes Favoris"
        case .aPropos: return "À Propos d'AutoDex"
        }
    }
    
    var icone: String {
        switch self {
        case .accueil: return "house.fill"
        case .collection: return "camera.fill"
        case .duel: return "arrow.left.arrow.right"
        case .quiz: return "gamecontroller.fill"
        case .decouverte: return "sparkles"
        case .favoris: return "heart.fill"
        case .aPropos: return "info.circle.fill"
        }
    }
    
    var couleurAccent: Color {
        switch self {
        case .accueil: return Color(red: 131/255, green: 170/255, blue: 131/255)
        case .collection: return .indigo
        case .duel: return .orange
        case .quiz: return .purple
        case .decouverte: return .blue
        case .favoris: return .red
        case .aPropos: return .gray
        }
    }
    
    var badgeTexte: String? {
        switch self {
        case .collection: return "Nouveau"
        default: return nil
        }
    }
}

// MARK: - Vue du Menu Tiroir Latéral
struct MenuTiroirView: View {
    @Binding var sectionSelectionnee: SectionNavigation
    @Binding var estOuvert: Bool
    @Query private var favoris: [FavoriteCar]
    @State private var authService = AuthService.shared
    @State private var confirmationDeconnexion: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Fond du tiroir
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - En-tête du Tiroir
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 131/255, green: 170/255, blue: 131/255).opacity(0.18))
                                .frame(width: 50, height: 50)
                            Image(systemName: "car.side.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AutoDex")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Le Pokédex Automobile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Bouton fermeture rapide
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                estOuvert = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color(.systemGray3))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Fermer le menu")
                        .accessibilityIdentifier("boutonFermerMenu")
                    }
                    
                    // Cartouche résumé
                    HStack(spacing: 12) {
                        statPill(valeur: "2 157", label: "Véhicules", icone: "car.2.fill", couleur: .blue)
                        statPill(valeur: "\(favoris.count)", label: "Favoris", icone: "heart.fill", couleur: .red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // MARK: - Liste des Sections de Navigation
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(SectionNavigation.allCases) { section in
                            let estActif = section == sectionSelectionnee
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    sectionSelectionnee = section
                                    estOuvert = false
                                }
                            }) {
                                HStack(spacing: 14) {
                                    // Icône dans son badge arrondi
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(section.couleurAccent.opacity(estActif ? 0.2 : 0.1))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: section.icone)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(section.couleurAccent)
                                    }
                                    
                                    // Titre
                                    Text(section.titreComplet)
                                        .font(.system(size: 15, weight: estActif ? .bold : .medium))
                                        .foregroundColor(estActif ? section.couleurAccent : .primary)
                                    
                                    Spacer()
                                    
                                    // Badge optionnel (Nouveau / Compteur favoris)
                                    if section == .favoris && !favoris.isEmpty {
                                        Text("\(favoris.count)")
                                            .font(.caption2.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.red)
                                            .clipShape(Capsule())
                                    } else if let badge = section.badgeTexte {
                                        Text(badge)
                                            .font(.caption2.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(section.couleurAccent)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(estActif ? section.couleurAccent.opacity(0.12) : Color.clear)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("menuItem_\(section.rawValue)")
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                }
                
                Spacer()
                
                // MARK: - Carte Utilisateur Connecté & Déconnexion
                if let utilisateur = authService.utilisateurCourant {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 131/255, green: 170/255, blue: 131/255).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Text(utilisateur.initiales)
                                    .font(.subheadline.bold())
                                    .foregroundColor(Color(red: 131/255, green: 170/255, blue: 131/255))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(utilisateur.nomOuEmail)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: utilisateur.fournisseur.iconeSysteme)
                                        .font(.caption2)
                                    Text(utilisateur.fournisseur.libelle)
                                        .font(.caption2)
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                confirmationDeconnexion = true
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Se déconnecter")
                            .accessibilityIdentifier("boutonDeconnexionMenu")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }
                }
                
                // MARK: - Pied de Page
                Divider()
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AutoDex • BUT Informatique")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text("Données 100% locales & gratuites")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: 310)
        .shadow(color: Color.black.opacity(0.18), radius: 20, x: 5, y: 0)
        .alert("Déconnexion", isPresented: $confirmationDeconnexion) {
            Button("Annuler", role: .cancel) {}
            Button("Se déconnecter", role: .destructive) {
                withAnimation {
                    estOuvert = false
                    authService.deconnexion()
                }
            }
        } message: {
            Text("Êtes-vous sûr de vouloir vous déconnecter d'AutoDex ?")
        }
    }
    
    private func statPill(valeur: String, label: String, icone: String, couleur: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icone)
                .font(.caption2)
                .foregroundColor(couleur)
            Text(valeur)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
