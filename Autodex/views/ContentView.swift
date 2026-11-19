//
//  ContentView.swift
//  Autodex
//
//  Created by Alyssia Frey on 29/05/2026.
//

import SwiftUI
import SwiftData

enum OngletAccueil: String, CaseIterable {
    case populaires = "Populaires"
    case nouveautes = "Nouveautés"
}

struct ContentView: View {
    @State private var viewModel = CarViewModel()
    @State private var searchText = ""
    @State private var ongletActif: OngletAccueil = .populaires
    
    // Pour les favoris
    @Query private var favoriteCars: [FavoriteCar]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 247/255, green: 247/255, blue: 249/255).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("AutoDex")
                        .font(.largeTitle)
                        .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                        .fontWeight(.bold)
                    
                    Text("Faites votre choix de véhicules en comparant leur caractéristiques")
                        .font(.caption)
                        .padding(.bottom, 20)
                    
                    // MARK: - Barre de recherche dynamique
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Rechercher un modèle (ex: clio, mustang...)", text: $searchText)
                            .font(.subheadline)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityLabel("Effacer la recherche")
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(25)
                    .padding(.bottom, 16)
                    
                    // MARK: - Filtres d'onglets (Populaires & Nouveautés des 6 derniers mois)
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                ongletActif = .populaires
                                searchText = ""
                            }
                            Task {
                                await viewModel.fetchTrendingCars()
                            }
                        }) {
                            Text("Populaires")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(ongletActif == .populaires ? Color.yellow : Color(.systemGray6))
                                .foregroundStyle(ongletActif == .populaires ? .black : .secondary)
                                .cornerRadius(30)
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                ongletActif = .nouveautes
                                searchText = ""
                            }
                            Task {
                                await viewModel.fetchNewReleases()
                            }
                        }) {
                            Text("Nouveautés")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(ongletActif == .nouveautes ? Color.yellow : Color(.systemGray6))
                                .foregroundStyle(ongletActif == .nouveautes ? .black : .secondary)
                                .cornerRadius(30)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 15)
                    
                    // MARK: - Liste Paginée (20 éléments par page)
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            if viewModel.isLoading {
                                ProgressView("Chargement des véhicules...")
                                    .padding(.top, 40)
                            } else if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .padding(.top, 40)
                            } else if viewModel.cars.isEmpty {
                                Text("Aucun véhicule à afficher. Essayez un autre modèle.")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                                    .padding(.top, 40)
                            } else {
                                ForEach(viewModel.carsAffichees) { car in
                                    let carId = "\((car.Make_Name ?? "").lowercased())-\((car.Model_Name ?? "").lowercased())"
                                    let isCarFavorite = favoriteCars.contains(where: { $0.id == carId })
                                    
                                    NavigationLink(destination: CarDetailView(car: car)) {
                                        CarLigne(
                                            marque: car.Make_Name ?? "Inconnu",
                                            titre: car.displayName,
                                            sousTitre: car.displaySubtitle,
                                            isFavorite: isCarFavorite,
                                            onFavoriteToggle: {
                                                toggleFavorite(for: car, isAlreadyFavorite: isCarFavorite, id: carId)
                                            }
                                        )
                                    }
                                    .onAppear {
                                        // Détection de fin de liste pour charger automatiquement la page suivante
                                        if car.id == viewModel.carsAffichees.last?.id {
                                            viewModel.chargerPageSuivante()
                                        }
                                    }
                                }
                                
                                // Bouton / indicateur de pagination si d'autres éléments sont disponibles
                                if viewModel.peutChargerPlus {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.chargerPageSuivante()
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Text("Afficher plus de véhicules (\(viewModel.carsAffichees.count) sur \(viewModel.cars.count))")
                                                .font(.footnote)
                                                .fontWeight(.medium)
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                    }
                                    .accessibilityIdentifier("boutonPagination")
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .task {
            await viewModel.fetchTrendingCars()
        }
        .onChange(of: searchText) { _, nouvelleValeur in
            Task {
                let texte = nouvelleValeur.trimmingCharacters(in: .whitespaces)
                if texte.isEmpty {
                    if ongletActif == .populaires {
                        await viewModel.fetchTrendingCars()
                    } else {
                        await viewModel.fetchNewReleases()
                    }
                } else {
                    await viewModel.fetchCars(searchQuery: texte)
                }
            }
        }
    }
    
    // MARK: - Gestion des favoris
    private func toggleFavorite(for car: Car, isAlreadyFavorite: Bool, id: String) {
        if isAlreadyFavorite {
            if let index = favoriteCars.firstIndex(where: { $0.id == id }) {
                modelContext.delete(favoriteCars[index])
            }
        } else {
            let newFavorite = FavoriteCar(
                make: car.Make_Name ?? "Inconnu",
                model: car.Model_Name ?? "Inconnu",
                year: car.year ?? 2026
            )
            modelContext.insert(newFavorite)
        }
    }
}

// MARK: - Ligne de Véhicule dans la Liste
struct CarLigne: View {
    var marque: String
    var titre: String
    var sousTitre: String
    var isFavorite: Bool
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Le logo constructeur prend la totalité du cercle
            LogoMarqueView(marque: marque, taille: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titre)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(sousTitre)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isFavorite ? .red : Color(.systemGray3))
            }
            .buttonStyle(.plain)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.systemGray3))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Barre de navigation principale
struct Navigationview: View {
    @Query private var favoriteCars: [FavoriteCar]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Accueil", systemImage: "house")
                }
            
            DecouverteView()
                .tabItem {
                    Label("Découverte", systemImage: "sparkles")
                }
            
            NavigationStack {
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    if favoriteCars.isEmpty {
                        ContentUnavailableView("Aucun favori", systemImage: "heart.slash", description: Text("Vos véhicules favoris s'afficheront ici."))
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(favoriteCars) { fav in
                                    HStack(spacing: 15) {
                                        LogoMarqueView(marque: fav.make, taille: 48)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(fav.make) \(fav.model)")
                                                .font(.headline)
                                            Text("Modèle \(fav.year)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(role: .destructive) {
                                            modelContext.delete(fav)
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Mes Favoris")
            }
            .tabItem {
                Label("Favoris", systemImage: "heart")
            }
        }
    }
}
