//
//  MaCollectionView.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import SwiftUI

struct MaCollectionView: View {
    var onOuvrirMenu: (() -> Void)? = nil
    @State private var afficherAlerteAjout: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // En-tête Collection
                        VStack(spacing: 8) {
                            Text("Ma Collection")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.indigo)
                            Text("Votre carnet de bord de bolides croisés et photographiés")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 10)
                        
                        // Cartouche de statistiques
                        HStack(spacing: 12) {
                            statItem(titre: "Spottés", valeur: "0", icone: "camera.fill", couleur: .indigo)
                            statItem(titre: "Rareté", valeur: "N/A", icone: "sparkles", couleur: .orange)
                            statItem(titre: "Marques", valeur: "0", icone: "flag.fill", couleur: .green)
                        }
                        .padding(.horizontal, 16)
                        
                        // État vide engageant
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.indigo.opacity(0.12))
                                    .frame(width: 90, height: 90)
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 42))
                                    .foregroundColor(.indigo)
                            }
                            
                            VStack(spacing: 6) {
                                Text("Aucune voiture immortalisée")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Photographiez une voiture de collection croisée dans la rue pour l'ajouter à votre Pokédex personnel.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            
                            // Boutons d'action
                            VStack(spacing: 10) {
                                Button(action: {
                                    afficherAlerteAjout = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                        Text("Prendre une Photo")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.indigo)
                                    .cornerRadius(14)
                                    .shadow(color: .indigo.opacity(0.3), radius: 6, x: 0, y: 3)
                                }
                                .accessibilityIdentifier("boutonPrendrePhotoCollection")
                                
                                Button(action: {
                                    afficherAlerteAjout = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                        Text("Importer depuis la Galerie")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.indigo)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.indigo.opacity(0.1))
                                    .cornerRadius(14)
                                }
                                .accessibilityIdentifier("boutonImporterPhotoCollection")
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 32)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onOuvrirMenu = onOuvrirMenu {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onOuvrirMenu) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .accessibilityLabel("Ouvrir le menu")
                        .accessibilityIdentifier("boutonMenuCollection")
                    }
                }
            }
            .alert("Module Spotting en cours d'intégration", isPresented: $afficherAlerteAjout) {
                Button("Compris", role: .cancel) {}
            } message: {
                Text("Le module de prise de vue et persistance SwiftData pour vos photos spottées est planifié dans le Chantier 3.")
            }
        }
    }
    
    private func statItem(titre: String, valeur: String, icone: String, couleur: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icone)
                .font(.subheadline)
                .foregroundColor(couleur)
            Text(valeur)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(titre)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}
