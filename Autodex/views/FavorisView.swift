//
//  FavorisView.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import SwiftUI
import SwiftData

struct FavorisView: View {
    @Query private var favoriteCars: [FavoriteCar]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CarViewModel()
    var onOuvrirMenu: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if favoriteCars.isEmpty {
                    ContentUnavailableView(
                        "Aucun favori",
                        systemImage: "heart.slash",
                        description: Text("Appuyez sur le cœur d'une fiche technique pour enregistrer vos véhicules favoris.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(favoriteCars) { fav in
                                let car = viewModel.trouverVehicule(pour: fav)
                                HStack(spacing: 15) {
                                    NavigationLink(destination: CarDetailView(car: car)) {
                                        HStack(spacing: 15) {
                                            LogoMarqueView(marque: fav.make, taille: 48)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(fav.make) \(fav.model)")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.primary)
                                                Text(car.displaySubtitle)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityIdentifier("favoriLink_\(fav.make)_\(fav.model)")
                                    
                                    Button(role: .destructive) {
                                        withAnimation {
                                            modelContext.delete(fav)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(8)
                                    }
                                    .buttonStyle(.plain)
                                    
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
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("favoriRow_\(fav.make)_\(fav.model)")
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mes Favoris")
            .toolbar {
                if let onOuvrirMenu = onOuvrirMenu {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onOuvrirMenu) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .accessibilityLabel("Ouvrir le menu")
                        .accessibilityIdentifier("boutonMenuFavoris")
                    }
                }
            }
        }
    }
}
