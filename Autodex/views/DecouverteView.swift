//
//  DecouverteView.swift
//  Autodex
//
//  Created by iutsd-mmi on 04/06/2026.
//

import SwiftUI
import SwiftData

struct DecouverteView: View {
    // 1. La vue gère son propre ViewModel de manière autonome
    @State private var viewModel = CarViewModel()
    @State private var currentRandomCar: Car?
    
    // 2. On prépare l'accès aux favoris (comme dans ton ContentView)
    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteCars: [FavoriteCar]
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Découverte")
                .font(.largeTitle)
                .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                .fontWeight(.bold)
            
            if let car = currentRandomCar {
                // --- LA CARTE ---
                VStack(spacing: 15) {
                    Image(systemName: "car.side.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                    
                    Text(car.Make_Name ?? "Inconnu")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(car.Model_Name ?? "Inconnu")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(40)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 30)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .slide))
                .id(car.id)
                
                // --- LES BOUTONS D'ACTION ---
                HStack(spacing: 60) {
                    // Bouton Je passe
                    Button(action: {
                        nextCar()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 70, height: 70)
                            .background(Color.red.opacity(0.15))
                            .clipShape(Circle())
                    }
                    
                    // Bouton J'ajoute aux Favoris
                    Button(action: {
                        let newFavorite = FavoriteCar(
                            make: car.Make_Name ?? "Inconnu",
                            model: car.Model_Name ?? "Inconnu",
                            year: car.year ?? 2026
                        )
                        modelContext.insert(newFavorite)
                        nextCar()
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.green)
                            .frame(width: 70, height: 70)
                            .background(Color.green.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            } else {
                VStack {
                    ProgressView("Recherche de pépites...")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .task {
            if viewModel.cars.isEmpty {
                await viewModel.fetchTrendingCars()
                nextCar()
            }
        }
    }
    
    private func nextCar() {
        guard !viewModel.cars.isEmpty else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentRandomCar = viewModel.cars.randomElement()
        }
    }
}
