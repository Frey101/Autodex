//
//  ContentView.swift
//  Autodex
//
//  Created by Alyssia Frey and Lucas Cesar on 29/05/2026.

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel = CarViewModel()
    @State private var searchText = ""
    @State private var detailVoiture = ""
    
    // Enregistrement des favoris
    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteCars: [FavoriteCar]
    
    var body : some View {
        
        NavigationStack{
            
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AutoDex")
                        .font(.largeTitle)
                        .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                        .fontWeight(.bold)
                    
                    Text("Faites votre choix de véhicules en comparant leur caractéristiques")
                        .font(.caption)
                        .padding(.bottom, 20)
                    
                    // Barre de recherche
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Rechercher un modèle (ex: clio, mustang...)", text: $searchText)
                            .font(.caption)
                            .onSubmit {
                                Task {
                                    await viewModel.fetchCars(searchQuery: searchText)
                                }
                            }
                        Spacer()
                    }
                    .padding(10)
                    .foregroundStyle(.black)
                    .background(Color(red: 225/255, green: 225/255, blue: 225/255))
                    .cornerRadius(25)
                    .padding(.bottom, 20)
                    
                    HStack {
                        Button("Populaires"){ }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.yellow)
                            .foregroundStyle(.black)
                            .cornerRadius(30)
                        
                        Button("Nouveautés"){ }
                            .foregroundStyle(.gray)
                    }
                    .padding(.bottom, 15)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
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
                                ForEach(viewModel.cars) { car in
                                    // ID unique théorique pour vérifier si le favori existe déjà
                                    let carId = "\((car.Make_Name ?? "").lowercased())-\((car.Model_Name ?? "").lowercased())"
                                    let isCarFavorite = favoriteCars.contains(where: { $0.id == carId })
                                    
                                    NavigationLink(destination: CarDetailView(car: car)){
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
    }
    
    // Fonction ajout ou supprime le favori
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
struct CarLigne: View {
    var marque: String
    var titre: String
    var sousTitre: String
    var isFavorite: Bool
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        
        HStack(spacing: 15) {
            Image(marque.lowercased())
                .resizable()
                .scaledToFit()
                .frame(width : 40, height : 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2),lineWidth: 1))
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titre)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text(sousTitre)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
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
                                ForEach(favoriteCars) { favorite in
                                    CarLigne(
                                        marque: favorite.make,
                                        titre: favorite.displayName,
                                        sousTitre: favorite.displaySubtitle,
                                        isFavorite: true,
                                        onFavoriteToggle: {
                                            // Permet de retirer des favoris directement depuis l'onglet Favoris
                                            modelContext.delete(favorite)
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                        .navigationTitle("Mes Favoris")
                    }
                }
            }
            .tabItem {
                Label("Favoris", systemImage: "heart")
            }
        }
        .tint(Color.blue)
    }
}

#Preview {
    Navigationview()
}
