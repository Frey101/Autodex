//
//  CarDetailView.swift
//  Autodex
//
//  Created by iutsd-mmi on 04/06/2026.
//
import SwiftUI

struct CarDetailView: View {
    var car: Car
    
    var body: some View {
        List {
            // En-tête avec Logo et Titres
            Section {
                VStack(spacing: 12) {
                    if let marque = car.Make_Name?.lowercased() {
                        Image(marque)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                    }
                    
                    Text(car.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(car.displaySubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .listRowBackground(Color.clear)
            }
            
            // Section 1 : Informations Générales
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
            
            // Section 2 : Motorisation & Performances
            Section(header: Text("Moteur & Transmission")) {
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
            
            // Section 3 : Dimensions & Consommation
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
    }
}
