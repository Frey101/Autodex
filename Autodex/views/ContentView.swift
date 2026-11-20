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
    var onOuvrirMenu: (() -> Void)? = nil
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
                    
                    // En-tête avec bouton Hamburger
                    HStack(spacing: 14) {
                        if let onOuvrirMenu = onOuvrirMenu {
                            Button(action: onOuvrirMenu) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Ouvrir le menu de navigation")
                            .accessibilityIdentifier("boutonMenuAccueil")
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AutoDex")
                                .font(.largeTitle)
                                .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
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
                        // Onglet 1 : Véhicules populaires
                        Button(action: {
                            guard ongletActif != .populaires else { return }
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
                        
                        // Onglet 2 : Nouveautés (sorties des 6 derniers mois)
                        Button(action: {
                            guard ongletActif != .nouveautes else { return }
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
                    .padding(.bottom, 10)
                    
                    // MARK: - Filtres Avancés (Énergie & Puissance)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Filtres Énergie
                            ForEach(FiltreEnergie.allCases) { energie in
                                let estActif = viewModel.filtreEnergieActif == energie
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.appliquerFiltres(energie: energie)
                                    }
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: energie.icone)
                                            .font(.system(size: 11))
                                        Text(energie.rawValue)
                                            .font(.system(size: 12, weight: estActif ? .bold : .medium))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(estActif ? Color(red: 131/255, green: 170/255, blue: 131/255) : Color(.systemGray6))
                                    .foregroundColor(estActif ? .white : .primary)
                                    .cornerRadius(18)
                                }
                                .accessibilityIdentifier("filtreEnergie_\(energie.rawValue)")
                            }
                            
                            Divider()
                                .frame(height: 18)
                                .padding(.horizontal, 4)
                            
                            // Filtres Puissance
                            ForEach(FiltrePuissance.allCases) { puissance in
                                let estActif = viewModel.filtrePuissanceActif == puissance
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.appliquerFiltres(puissance: puissance)
                                    }
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 11))
                                        Text(puissance.rawValue)
                                            .font(.system(size: 12, weight: estActif ? .bold : .medium))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(estActif ? Color.orange : Color(.systemGray6))
                                    .foregroundColor(estActif ? .white : .primary)
                                    .cornerRadius(18)
                                }
                                .accessibilityIdentifier("filtrePuissance_\(puissance.rawValue)")
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                    .padding(.bottom, 12)
                    
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
                                    
                                    CarLigne(
                                        car: car,
                                        isFavorite: isCarFavorite,
                                        onFavoriteToggle: {
                                            toggleFavorite(for: car, isAlreadyFavorite: isCarFavorite, id: carId)
                                        }
                                    )
                                }
                                
                                // Indicateur et bouton de pagination interactif avec déclenchement automatique
                                if viewModel.peutChargerPlus {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.chargerPageSuivante()
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("Afficher plus de véhicules (\(viewModel.carsAffichees.count) sur \(viewModel.cars.count))")
                                                .font(.footnote)
                                                .fontWeight(.medium)
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    .accessibilityIdentifier("boutonPagination")
                                    .onAppear {
                                        // Chargement automatique lors du défilement au bas de la page
                                        viewModel.chargerPageSuivante()
                                    }
                                } else if !viewModel.carsAffichees.isEmpty {
                                    Text("Tous les véhicules sont affichés (\(viewModel.carsAffichees.count))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
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
    var car: Car
    var isFavorite: Bool
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            NavigationLink(destination: CarDetailView(car: car)) {
                HStack(spacing: 15) {
                    LogoMarqueView(marque: car.Make_Name ?? "Inconnu", taille: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(car.displayName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text(car.displaySubtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("carCardLink")
            
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isFavorite ? .red : Color(.systemGray3))
                    .padding(8)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("boutonCoeurLigne")
            
            NavigationLink(destination: CarDetailView(car: car)) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Navigation Principale avec Menu Tiroir Latéral (Side Drawer)
struct Navigationview: View {
    @State private var sectionCourante: SectionNavigation = .accueil
    @State private var menuOuvert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let largeurTiroir = min(geometry.size.width * 0.82, 320.0)
            
            ZStack(alignment: .leading) {
                // 1. Vue principale correspondant à la section active
                Group {
                    switch sectionCourante {
                    case .accueil:
                        ContentView(onOuvrirMenu: toggleMenu)
                    case .collection:
                        MaCollectionView(onOuvrirMenu: toggleMenu)
                    case .duel:
                        ComparateurView(onOuvrirMenu: toggleMenu)
                    case .quiz:
                        QuizView(onOuvrirMenu: toggleMenu)
                    case .decouverte:
                        DecouverteView(onOuvrirMenu: toggleMenu)
                    case .favoris:
                        FavorisView(onOuvrirMenu: toggleMenu)
                    case .aPropos:
                        AProposView(onOuvrirMenu: toggleMenu)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .disabled(menuOuvert) // Désactive les interactions sur le contenu lorsque le menu est ouvert
                
                // 2. Fond assombrissant interactif avec fondu animé & Panneau Tiroir
                if menuOuvert {
                    Color.black
                        .opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            fermerMenu()
                        }
                    
                    MenuTiroirView(sectionSelectionnee: $sectionCourante, estOuvert: $menuOuvert)
                        .frame(width: largeurTiroir)
                        .transition(.move(edge: .leading))
                        .shadow(color: Color.black.opacity(0.25), radius: 16, x: 8, y: 0)
                }
            }
        }
    }
    
    private func toggleMenu() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            menuOuvert.toggle()
        }
    }
    
    private func fermerMenu() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            menuOuvert = false
        }
    }
}
