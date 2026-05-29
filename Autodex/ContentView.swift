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
    
    var body : some View {
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
                
                // Appel sur l'instance viewModel
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
                                CarLigne(
                                    logoName: "car.fill",
                                    titre: car.displayName,
                                    sousTitre: car.displaySubtitle
                                )
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        // Déclenchement de la requête au démarrage de l'écran
        .task {
            await viewModel.fetchTrendingCars()
        }
    }
}

struct CarLigne: View {
    var logoName: String
    var titre: String
    var sousTitre: String
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(titre.prefix(1)))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titre)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text(sousTitre)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
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
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Accueil", systemImage: "house")
                }
            
            Text("Deuxieme Tab")
                .tabItem {
                    Label("Véhicules", systemImage: "car")
                }
            
            Text("Troisieme Tab")
                .tabItem {
                    Label("Comparer", systemImage: "scalemass")
                }
            
            Text("Quatrieme Tab")
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
