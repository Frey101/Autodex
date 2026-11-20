//
//  DecouverteView.swift
//  Autodex
//
//  Created by iutsd-mmi on 04/06/2026.
//

import SwiftUI
import SwiftData

struct DecouverteView: View {
    @State private var viewModel = CarViewModel()
    @State private var currentRandomCar: Car?
    @State private var wikiPhotoUrl: String? = nil
    @State private var estEnChargementPhoto: Bool = false
    @State private var glissement: CGSize = .zero
    @State private var versDetail: Bool = false
    var onOuvrirMenu: (() -> Void)? = nil
    
    // Accès SwiftData aux favoris
    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteCars: [FavoriteCar]
    
    var estDejaFavori: Bool {
        guard let car = currentRandomCar else { return false }
        let id = "\(car.Make_Name ?? "")-\(car.Model_Name ?? "")".lowercased()
        return favoriteCars.contains(where: { $0.id == id })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
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
                        .accessibilityLabel("Ouvrir le menu")
                        .accessibilityIdentifier("boutonMenuDecouverte")
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Découverte")
                            .font(.largeTitle)
                            .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                            .fontWeight(.bold)
                        Text("Tirez une carte au hasard façon Pokédex")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                if let car = currentRandomCar {
                    // --- CARTE POKÉDEX AUTOMOBILE ---
                    carteVehicule(car: car)
                        .offset(x: glissement.width, y: glissement.height * 0.2)
                        .rotationEffect(.degrees(Double(glissement.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { valeur in
                                    glissement = valeur.translation
                                }
                                .onEnded { valeur in
                                    if valeur.translation.width > 120 {
                                        // Glissement à droite -> Favori
                                        ajouterAuxFavoris()
                                    } else if valeur.translation.width < -120 {
                                        // Glissement à gauche -> Passer
                                        passerVehicule()
                                    } else {
                                        withAnimation(.spring()) {
                                            glissement = .zero
                                        }
                                    }
                                }
                        )
                        .padding(.horizontal, 24)
                        .navigationDestination(isPresented: $versDetail) {
                            CarDetailView(car: car)
                        }
                    
                    Spacer()
                    
                    // --- LES BOUTONS D'ACTION ---
                    HStack(spacing: 36) {
                        // Bouton Passer (Croix rouge)
                        Button(action: passerVehicule) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 58, height: 58)
                                .background(Color.red.opacity(0.12))
                                .clipShape(Circle())
                                .shadow(color: Color.red.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                        .accessibilityIdentifier("boutonPasserDecouverte")
                        
                        // Bouton Consulter Fiche Technique (Info / Oeil)
                        Button(action: { versDetail = true }) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.12))
                                .clipShape(Circle())
                        }
                        .accessibilityIdentifier("boutonConsulterFicheDecouverte")
                        
                        // Bouton Favoris (Cœur vert / rouge si déjà favori)
                        Button(action: ajouterAuxFavoris) {
                            Image(systemName: estDejaFavori ? "heart.fill" : "heart")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(estDejaFavori ? .red : .green)
                                .frame(width: 58, height: 58)
                                .background((estDejaFavori ? Color.red : Color.green).opacity(0.12))
                                .clipShape(Circle())
                                .shadow(color: (estDejaFavori ? Color.red : Color.green).opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                        .accessibilityIdentifier("boutonFavoriDecouverte")
                    }
                    .padding(.bottom, 16)
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.3)
                        Text("Recherche de pépites automobiles...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .task {
                if viewModel.cars.isEmpty {
                    await viewModel.fetchTrendingCars()
                    prochainVehicule()
                }
            }
        }
    }
    
    // MARK: - Carte Visuelle du Véhicule
    @ViewBuilder
    private func carteVehicule(car: Car) -> some View {
        Button(action: {
            versDetail = true
        }) {
            VStack(spacing: 16) {
                // En-tête de la carte : Logo et Marque
                HStack(spacing: 12) {
                    LogoMarqueView(marque: car.Make_Name ?? "", taille: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(car.Make_Name ?? "Inconnu")
                            .font(.headline)
                            .foregroundColor(.primary)
                        if let categorie = car.vehicleClass {
                            Text(categorie.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if estDejaFavori {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 4)
                
                // Photo du véhicule ou placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 190)
                    
                    if let photoUrl = wikiPhotoUrl, let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 190)
                                    .clipped()
                                    .cornerRadius(16)
                            case .failure:
                                vuePhotoSecours(marque: car.Make_Name)
                            @unknown default:
                                vuePhotoSecours(marque: car.Make_Name)
                            }
                        }
                    } else if estEnChargementPhoto {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Chargement de la photo...")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        vuePhotoSecours(marque: car.Make_Name)
                    }
                }
                
                // Nom du modèle
                VStack(spacing: 6) {
                    Text(car.Model_Name ?? "Inconnu")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                // Badges de caractéristiques clés (Année, Puissance, Carburant)
                HStack(spacing: 8) {
                    if let annee = car.year {
                        badgeCaracteristique(icone: "calendar", valeur: "\(annee)", couleur: .blue)
                    }
                    if let hp = car.horsepower {
                        badgeCaracteristique(icone: "bolt.fill", valeur: "\(hp) ch", couleur: .orange)
                    }
                    if let carburant = car.displayFuelType {
                        badgeCaracteristique(icone: "fuelpump.fill", valeur: carburant, couleur: .green)
                    }
                }
                
                // Indication tactile
                HStack(spacing: 6) {
                    Text("Appuyez pour voir la fiche technique")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("carteDecouverte")
    }
    
    // MARK: - Badge de Caractéristique Visuelle
    private func badgeCaracteristique(icone: String, valeur: String, couleur: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icone)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(couleur)
            Text(valeur)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(couleur.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Visuel de Secours
    @ViewBuilder
    private func vuePhotoSecours(marque: String?) -> some View {
        VStack(spacing: 10) {
            if let marque = marque {
                LogoMarqueView(marque: marque, taille: 70)
            } else {
                Image("voiture")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
            }
        }
    }
    
    // MARK: - Actions Utilisateur
    private func prochainVehicule() {
        guard !viewModel.cars.isEmpty else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentRandomCar = viewModel.cars.randomElement()
            glissement = .zero
        }
        chargerPhotoPourVehiculeCourant()
    }
    
    private func passerVehicule() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeOut(duration: 0.2)) {
            glissement = CGSize(width: -400, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            prochainVehicule()
        }
    }
    
    private func ajouterAuxFavoris() {
        guard let car = currentRandomCar else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let newFavorite = FavoriteCar(
            make: car.Make_Name ?? "Inconnu",
            model: car.Model_Name ?? "Inconnu",
            year: car.year ?? 2026
        )
        modelContext.insert(newFavorite)
        
        withAnimation(.easeOut(duration: 0.2)) {
            glissement = CGSize(width: 400, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            prochainVehicule()
        }
    }
    
    private func chargerPhotoPourVehiculeCourant() {
        guard let car = currentRandomCar,
              let marque = car.Make_Name,
              let modele = car.Model_Name else {
            wikiPhotoUrl = nil
            return
        }
        
        wikiPhotoUrl = nil
        estEnChargementPhoto = true
        
        Task {
            let detail = await WikipediaService.shared.chargerInfosVehicule(marque: marque, modele: modele)
            if currentRandomCar?.id == car.id {
                wikiPhotoUrl = detail?.photoUrl
                estEnChargementPhoto = false
            }
        }
    }
}
