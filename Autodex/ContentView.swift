//
//  ContentView.swift
//  Autodex
//
//  Created by Alyssia Frey and Lucas Cesar on 29/05/2026.

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body : some View {
        // On utilise une ZStack pour mettre un fond coloré sur tout l'écran
        ZStack {
            // Fond gris clair standard iOS pour faire ressortir les éléments blancs
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 4) {
                
                // Titre
                Text("AutoDex")
                    .font(.largeTitle)
                    .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))
                    .fontWeight(.bold)
                
                // Texte recherche
                Text("Faites votre choix de véhicules en comparant leur caractéristiques")
                    .font(.caption)
                    .padding(.bottom, 20)
                
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Rechercher un véhicule", text: .constant(""))
                        .font(.caption)
                    Spacer()
                }
                .padding(10)
                .foregroundStyle(.black)
                .background(Color(red: 225/255, green: 225/255, blue: 225/255))
                .cornerRadius(25)
                .padding(.bottom, 20)
                
                // Filtres
                HStack {
                    Button("Populaires"){ }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .foregroundStyle(.black) // Texte lisible sur le jaune
                        .cornerRadius(30)
                    
                    Button("Nouveautés"){ }
                        .foregroundStyle(.gray)
                }
                .padding(.bottom, 15)
                
                // Liste des voitures déroulable
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12){
                        CarLigne(logoName: "tesla_logo", titre: "Tesla Model 3", sousTitre: "2023 - Electrique")
                        CarLigne(logoName: "tesla_logo", titre: "Tesla Model 3", sousTitre: "2023 - Electrique")
                        CarLigne(logoName: "tesla_logo", titre: "Tesla Model 3", sousTitre: "2023 - Electrique")
                        CarLigne(logoName: "tesla_logo", titre: "Tesla Model 3", sousTitre: "2023 - Electrique")
                        CarLigne(logoName: "tesla_logo", titre: "Tesla Model 3", sousTitre: "2023 - Electrique")
                    }
                    .padding(.bottom, 20) // Petit espace pour ne pas coller au niveau de la TabView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
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
                        .foregroundColor(.white) // Mis en blanc pour une meilleure lisibilité sur fond gris
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

// Correction des Labels et intégration de HomeView au bon endroit
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
