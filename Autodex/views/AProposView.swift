//
//  AProposView.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import SwiftUI

struct AProposView: View {
    var onOuvrirMenu: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo et Nom
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 131/255, green: 170/255, blue: 131/255).opacity(0.15))
                                    .frame(width: 90, height: 90)
                                Image(systemName: "car.side.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                            }
                            
                            Text("AutoDex")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Version 1.2 • Projet Universitaire")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                        
                        // Fiche BUT Informatique
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Contexte Académique", systemImage: "graduationcap.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("AutoDex est conçu comme le « Pokédex » automobile sur iOS dans le cadre de la formation BUT Informatique. L'application met en œuvre les technologies modernes du développement mobile sous l'écosystème Apple.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineSpacing(3)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // Stack Technique
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Architecture & Technologies", systemImage: "cpu")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ligneTechnique(titre: "Framework UI", valeur: "SwiftUI (iOS 16+)")
                            ligneTechnique(titre: "Gestion d'état", valeur: "@Observable (Framework Observation)")
                            ligneTechnique(titre: "Persistance", valeur: "SwiftData (Modèle FavoriteCar)")
                            ligneTechnique(titre: "Concurrence", valeur: "async/await, TaskGroup, @MainActor")
                            ligneTechnique(titre: "Tests", valeur: "84+ tests automatisés (XCTest & XCUITest)")
                            ligneTechnique(titre: "APIs & Données", valeur: "100% gratuites (Dataset local, NHTSA, Wikipédia)")
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // Statistiques du Catalogue
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Données Embarquées", systemImage: "cylinder.split.1x2.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ligneTechnique(titre: "Véhicules indexés", valeur: "2 157 modèles")
                            ligneTechnique(titre: "Constructeurs", valeur: "60+ marques officielles")
                            ligneTechnique(titre: "Millésimes", valeur: "De 1895 aux nouveautés 2026")
                            ligneTechnique(titre: "Mode Hors-ligne", valeur: "Disponible intégralement")
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("À Propos")
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
                        .accessibilityIdentifier("boutonMenuAPropos")
                    }
                }
            }
        }
    }
    
    private func ligneTechnique(titre: String, valeur: String) -> some View {
        HStack {
            Text(titre)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(valeur)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}
