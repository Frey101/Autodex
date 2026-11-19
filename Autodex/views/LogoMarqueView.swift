//
//  LogoMarqueView.swift
//  Autodex
//
//  Composant SwiftUI d'affichage du logo constructeur avec mise à l'échelle optimale,
//  mise en cache réseau et système de repli.
//

import SwiftUI

struct LogoMarqueView: View {
    let marque: String
    var taille: CGFloat = 38
    
    var body: some View {
        let nomMarque = marque.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Priorité au logo haute résolution transparent du CDN (avec cache mémoire & disque)
        if let url = BrandLogoService.shared.urlLogo(pour: marque) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .frame(width: taille, height: taille)
                case .failure:
                    vueRepliLocal(nomMarque: nomMarque)
                case .empty:
                    vueRepliLocal(nomMarque: nomMarque)
                @unknown default:
                    vueRepliLocal(nomMarque: nomMarque)
                }
            }
        } else {
            vueRepliLocal(nomMarque: nomMarque)
        }
    }
    
    // MARK: - Repli local (assets du bundle ou image de secours générique)
    @ViewBuilder
    private func vueRepliLocal(nomMarque: String) -> some View {
        if UIImage(named: nomMarque) != nil {
            Image(nomMarque)
                .resizable()
                .scaledToFit()
                .padding(2)
                .frame(width: taille, height: taille)
        } else {
            Image("voiture")
                .resizable()
                .scaledToFit()
                .frame(width: taille * 0.85, height: taille * 0.85)
        }
    }
}
