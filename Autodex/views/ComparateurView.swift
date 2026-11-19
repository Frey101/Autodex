//
//  ComparateurView.swift
//  Autodex
//
//  Created by iutsd-mmi on 04/06/2026.
//

import SwiftUI

struct ComparateurView: View {
    @State private var viewModel = CarViewModel()
    @State private var voiture1: Car? = nil
    @State private var voiture2: Car? = nil
    
    // États pour le sélecteur de véhicule modal
    @State private var afficherSelecteur1: Bool = false
    @State private var afficherSelecteur2: Bool = false
    @State private var texteRecherche: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête
                    VStack(spacing: 4) {
                        Text("Comparateur Duel")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                        Text("Face-à-face technique façon Pokédex")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // MARK: - Sélecteurs des deux véhicules (Côte à côte)
                    HStack(spacing: 12) {
                        // Carte Véhicule 1
                        slotVehicule(car: voiture1, index: 1) {
                            afficherSelecteur1 = true
                        }
                        
                        // Badge VS central
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                                .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 3)
                            Text("VS")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.white)
                        }
                        
                        // Carte Véhicule 2
                        slotVehicule(car: voiture2, index: 2) {
                            afficherSelecteur2 = true
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - Boutons d'Action Rapide (Aléatoire / Échanger)
                    HStack(spacing: 16) {
                        Button(action: { duelAleatoire() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "dice.fill")
                                Text("Duel Aléatoire")
                            }
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                        }
                        .accessibilityIdentifier("boutonDuelAleatoire")
                        
                        if voiture1 != nil && voiture2 != nil {
                            Button(action: echangerVehicules) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("Inverser")
                                }
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // MARK: - Tableau Comparatif Détaillé
                    if let car1 = voiture1, let car2 = voiture2 {
                        let comp = ComparaisonVehicules(car1: car1, car2: car2)
                        
                        VStack(spacing: 16) {
                            // Bannière du Verdict
                            VStack(spacing: 6) {
                                Text("🏆 Verdict du Duel")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .foregroundColor(.secondary)
                                Text(comp.verdictTexte)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(comp.scoreCar1 != comp.scoreCar2 ? .green : .primary)
                                    .multilineTextAlignment(.center)
                                
                                HStack(spacing: 20) {
                                    Text("\(comp.scoreCar1) pts")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(comp.scoreCar1 > comp.scoreCar2 ? .green : .secondary)
                                    Text("-")
                                    Text("\(comp.scoreCar2) pts")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(comp.scoreCar2 > comp.scoreCar1 ? .green : .secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 16)
                            
                            // Liste des spécifications comparées
                            VStack(spacing: 12) {
                                ligneComparaison(
                                    titre: "Puissance",
                                    val1: car1.horsepower != nil ? "\(car1.horsepower!) ch" : "N/A",
                                    val2: car2.horsepower != nil ? "\(car2.horsepower!) ch" : "N/A",
                                    gagnant: comp.gagnantPuissance,
                                    icone: "bolt.fill"
                                )
                                
                                ligneComparaison(
                                    titre: "Cylindrée",
                                    val1: car1.displacement != nil ? String(format: "%.1f L", car1.displacement!) : "N/A",
                                    val2: car2.displacement != nil ? String(format: "%.1f L", car2.displacement!) : "N/A",
                                    gagnant: comp.gagnantCylindree,
                                    icone: "gauge.with.needle.fill"
                                )
                                
                                ligneComparaison(
                                    titre: "Conso. Autoroute",
                                    val1: car1.highwayMpg != nil ? "\(car1.highwayMpg!) MPG" : "N/A",
                                    val2: car2.highwayMpg != nil ? "\(car2.highwayMpg!) MPG" : "N/A",
                                    gagnant: comp.gagnantConso,
                                    icone: "leaf.fill"
                                )
                                
                                ligneComparaisonNeutre(
                                    titre: "Année",
                                    val1: car1.year != nil ? "\(car1.year!)" : "N/A",
                                    val2: car2.year != nil ? "\(car2.year!)" : "N/A",
                                    icone: "calendar"
                                )
                                
                                ligneComparaisonNeutre(
                                    titre: "Énergie",
                                    val1: (car1.fuelType ?? "N/A").capitalized,
                                    val2: (car2.fuelType ?? "N/A").capitalized,
                                    icone: "fuelpump.fill"
                                )
                                
                                ligneComparaisonNeutre(
                                    titre: "Transmission",
                                    val1: car1.transmission == "a" ? "Auto" : car1.transmission == "m" ? "Manuelle" : (car1.transmission ?? "N/A").capitalized,
                                    val2: car2.transmission == "a" ? "Auto" : car2.transmission == "m" ? "Manuelle" : (car2.transmission ?? "N/A").capitalized,
                                    icone: "gearshape.fill"
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        .id("comparatif_\(car1.id)_\(car2.id)")
                        .transition(.opacity)
                    } else {
                        // Guide d'aide quand moins de 2 véhicules sont sélectionnés
                        VStack(spacing: 12) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                            Text("Sélectionnez 2 véhicules pour lancer le comparatif !")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Touchez un emplacement ci-dessus ou cliquez sur « Duel Aléatoire ».")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .id("comparatif_vide")
                        .transition(.opacity)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $afficherSelecteur1) {
                vueSelectionVehicule(titre: "Sélectionner le Véhicule 1") { selectionnee in
                    voiture1 = selectionnee
                }
            }
            .sheet(isPresented: $afficherSelecteur2) {
                vueSelectionVehicule(titre: "Sélectionner le Véhicule 2") { selectionnee in
                    voiture2 = selectionnee
                }
            }
            .task {
                if voiture1 == nil && voiture2 == nil && !viewModel.catalogueLocal.isEmpty {
                    duelAleatoire(anime: false)
                }
            }
        }
    }
    
    // MARK: - Emplacement de Véhicule (Slot)
    @ViewBuilder
    private func slotVehicule(car: Car?, index: Int, onSelect: @escaping () -> Void) -> some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                if let car = car {
                    LogoMarqueView(marque: car.Make_Name ?? "", taille: 46)
                    
                    VStack(spacing: 2) {
                        Text(car.Make_Name ?? "Inconnu")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(car.Model_Name ?? "Inconnu")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("Changer")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 46, height: 46)
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                    Text("Choisir Véhicule \(index)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .compositingGroup()
        }
        .buttonStyle(.plain)
        .id(car?.id.uuidString ?? "slot_vide_\(index)")
        .accessibilityIdentifier("slotVehicule\(index)")
    }
    
    // MARK: - Ligne de Comparaison avec Gagnant
    @ViewBuilder
    private func ligneComparaison(titre: String, val1: String, val2: String, gagnant: Int?, icone: String) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icone)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(titre)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                // Valeur 1
                HStack(spacing: 4) {
                    Text(val1)
                        .font(.system(size: 15, weight: gagnant == 1 ? .bold : .medium))
                        .foregroundColor(gagnant == 1 ? .green : .primary)
                    if gagnant == 1 {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Divider()
                    .frame(height: 20)
                
                // Valeur 2
                HStack(spacing: 4) {
                    Text(val2)
                        .font(.system(size: 15, weight: gagnant == 2 ? .bold : .medium))
                        .foregroundColor(gagnant == 2 ? .green : .primary)
                    if gagnant == 2 {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Ligne Neutre (Informations)
    @ViewBuilder
    private func ligneComparaisonNeutre(titre: String, val1: String, val2: String, icone: String) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icone)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(titre)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(val1)
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(1)
                Divider()
                    .frame(height: 20)
                Text(val2)
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Modal de Sélection d'un Véhicule
    @ViewBuilder
    private func vueSelectionVehicule(titre: String, onSelect: @escaping (Car) -> Void) -> some View {
        NavigationStack {
            VStack {
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher un modèle...", text: $texteRecherche)
                    if !texteRecherche.isEmpty {
                        Button(action: { texteRecherche = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                let resultats = viewModel.catalogueLocal.filter { car in
                    if texteRecherche.isEmpty { return true }
                    return car.displayName.localizedCaseInsensitiveContains(texteRecherche) ||
                           (car.Make_Name ?? "").localizedCaseInsensitiveContains(texteRecherche)
                }
                
                List(resultats.prefix(50)) { car in
                    Button(action: {
                        onSelect(car)
                        afficherSelecteur1 = false
                        afficherSelecteur2 = false
                        texteRecherche = ""
                    }) {
                        HStack(spacing: 12) {
                            LogoMarqueView(marque: car.Make_Name ?? "", taille: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(car.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(car.displaySubtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(titre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        afficherSelecteur1 = false
                        afficherSelecteur2 = false
                        texteRecherche = ""
                    }
                }
            }
        }
    }
    
    // MARK: - Actions Duel
    private func duelAleatoire(anime: Bool = true) {
        guard viewModel.catalogueLocal.count >= 2 else { return }
        let c1 = viewModel.catalogueLocal.randomElement()
        let c2 = viewModel.catalogueLocal.filter { $0.id != c1?.id }.randomElement()
        if anime {
            withAnimation(.easeInOut(duration: 0.2)) {
                voiture1 = c1
                voiture2 = c2
            }
        } else {
            voiture1 = c1
            voiture2 = c2
        }
    }
    
    private func echangerVehicules() {
        withAnimation(.spring()) {
            let temp = voiture1
            voiture1 = voiture2
            voiture2 = temp
        }
    }
}
