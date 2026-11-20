//
//  VoitureDuJourWidgetView.swift
//  AutodexWidget
//
//  Created by Tom Tas on 20/11/2026.
//

import SwiftUI
import WidgetKit

struct VoitureDuJourWidgetEntryView: View {
    var entry: VoitureDuJourEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                VueWidgetPetit(voiture: entry.voiture)
            case .systemMedium:
                VueWidgetMoyen(voiture: entry.voiture)
            default:
                VueWidgetMoyen(voiture: entry.voiture)
            }
        }
        .widgetURL(entry.voiture.deepLinkURL)
    }
}

// MARK: - Format Petit (.systemSmall)
struct VueWidgetPetit: View {
    let voiture: WidgetCarData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // En-tête : Badge AutoDex et icône
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9))
                    Text("DU JOUR")
                        .font(.system(size: 9, weight: .black))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.18))
                .clipShape(Capsule())
                
                Spacer()
                
                Image(systemName: "car.side.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.75))
            }
            
            Spacer(minLength: 2)
            
            // Marque & Modèle
            VStack(alignment: .leading, spacing: 2) {
                Text(voiture.make.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.65))
                
                Text(voiture.model)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            
            Spacer(minLength: 2)
            
            // Badges Techniques (Puissance & Année)
            HStack(spacing: 4) {
                if let hp = voiture.horsepower {
                    HStack(spacing: 2) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 8))
                        Text("\(hp) ch")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2.5)
                    .background(Color.yellow.opacity(0.18))
                    .cornerRadius(5)
                }
                
                Text("\(voiture.year)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2.5)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(5)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 22/255, green: 27/255, blue: 38/255),
                    Color(red: 14/255, green: 17/255, blue: 25/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Format Moyen (.systemMedium)
struct VueWidgetMoyen: View {
    let voiture: WidgetCarData
    
    var body: some View {
        HStack(spacing: 12) {
            // Colonne Gauche : Identité & Badges
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                    Text("VOITURE DU JOUR")
                        .font(.system(size: 9, weight: .black))
                }
                .foregroundColor(.cyan)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.cyan.opacity(0.18))
                .clipShape(Capsule())
                
                Spacer(minLength: 2)
                
                Text(voiture.make.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.65))
                
                Text(voiture.model)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 2)
                
                HStack(spacing: 6) {
                    if let hp = voiture.horsepower {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 9))
                            Text("\(hp) ch")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.18))
                        .cornerRadius(6)
                    }
                    
                    Text("\(voiture.year)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Séparateur vertical discret
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 1)
                .padding(.vertical, 4)
            
            // Colonne Droite : Anecdote & Appel à l'action
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if let carburant = voiture.fuelType {
                        Text(carburant)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(5)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer(minLength: 2)
                
                Text(voiture.anecdote)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(3)
                    .lineSpacing(2)
                
                Spacer(minLength: 2)
                
                HStack(spacing: 4) {
                    Text("Ouvrir la fiche")
                        .font(.system(size: 10, weight: .bold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 10))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue)
                .cornerRadius(6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 20/255, green: 25/255, blue: 36/255),
                    Color(red: 12/255, green: 15/255, blue: 22/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
