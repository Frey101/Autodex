//
//  CarDetailView.swift
//  Autodex
//
//  Created by iutsd-mmi on 04/06/2026.
//

import SwiftUI

struct CarDetailView: View {
    var car: Car
    
    // État pour les données Wikipédia asynchrones
    @State private var wikiDetail: DetailWikipedia? = nil
    @State private var estEnChargementWiki: Bool = false
    
    var body: some View {
        List {
            // MARK: - En-tête Visuel (Photo Wikipédia ou Logo avec Titres)
            Section {
                VStack(spacing: 14) {
                    // Affichage de la photo dynamique ou de l'image de secours
                    if let photoUrl = wikiDetail?.photoUrl, let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.secondarySystemBackground))
                                        .frame(height: 200)
                                    ProgressView()
                                }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 220)
                                    .clipped()
                                    .cornerRadius(14)
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            case .failure:
                                vueImageSecours
                            @unknown default:
                                vueImageSecours
                            }
                        }
                    } else if estEnChargementWiki {
                        ZStack {
                            vueImageSecours
                            ProgressView()
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    } else {
                        vueImageSecours
                    }
                    
                    // Titre et sous-titre
                    VStack(spacing: 4) {
                        Text(car.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(car.displaySubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
            
            // MARK: - Section Histoire & Présentation (Wikipédia)
            if let resume = wikiDetail?.resume, !resume.isEmpty {
                Section(header: Text("Histoire & Présentation")) {
                    Text(resume)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                    
                    if let pageUrl = wikiDetail?.pageUrl, let url = URL(string: pageUrl) {
                        Link(destination: url) {
                            HStack {
                                Text("Lire l'article complet sur Wikipédia")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                            }
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                        }
                    }
                    
                    Text("Source : Wikipédia (Licence CC-BY-SA 4.0)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else if estEnChargementWiki {
                Section(header: Text("Histoire & Présentation")) {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Recherche des informations Wikipédia...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // MARK: - Section 1 : Informations Générales
            Section(header: Text("Général")) {
                LabeledContent("Marque", value: car.Make_Name ?? "N/A")
                LabeledContent("Modèle", value: car.Model_Name ?? "N/A")
                if let year = car.year {
                    LabeledContent("Année", value: String(year))
                }
                if let classType = car.vehicleClass {
                    LabeledContent("Catégorie", value: classType.capitalized)
                }
            }
            
            // MARK: - Section 2 : Motorisation & Performances
            Section(header: Text("Moteur & Transmission")) {
                if let engine = car.engineName {
                    LabeledContent("Moteur", value: engine)
                }
                if let hp = car.horsepower {
                    LabeledContent("Puissance", value: "\(hp) ch")
                }
                if let fuel = car.fuelType {
                    LabeledContent("Carburant", value: fuel.capitalized)
                }
                if let cylinders = car.cylinders {
                    LabeledContent("Cylindres", value: "\(cylinders)")
                }
                if let displacement = car.displacement {
                    LabeledContent("Cylindrée", value: String(format: "%.1f L", displacement))
                }
                if let transmission = car.transmission {
                    LabeledContent("Transmission", value: transmission == "a" ? "Automatique" : transmission == "m" ? "Manuelle" : transmission.capitalized)
                }
                if let drive = car.drive {
                    LabeledContent("Traction", value: drive.capitalized)
                }
            }
            
            // MARK: - Section 3 : Dimensions & Consommation
            Section(header: Text("Efficacité")) {
                if let cityMpg = car.cityMpg {
                    LabeledContent("Conso. Ville", value: "\(cityMpg) MPG")
                }
                if let highwayMpg = car.highwayMpg {
                    LabeledContent("Conso. Autoroute", value: "\(highwayMpg) MPG")
                }
            }
        }
        .navigationTitle("Fiche Technique")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await chargerInfosWikipedia()
        }
    }
    
    // MARK: - Vue de secours pour l'image (Logo de la marque ou icône par défaut)
    @ViewBuilder
    private var vueImageSecours: some View {
        if let marque = car.Make_Name {
            LogoMarqueView(marque: marque, taille: 80)
                .padding(.vertical, 8)
        } else {
            Image("voiture")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .padding(.vertical, 8)
        }
    }
    
    // MARK: - Chargement asynchrone des données Wikipédia
    private func chargerInfosWikipedia() async {
        guard let marque = car.Make_Name, let modele = car.Model_Name else { return }
        estEnChargementWiki = true
        wikiDetail = await WikipediaService.shared.chargerInfosVehicule(marque: marque, modele: modele)
        estEnChargementWiki = false
    }
}
