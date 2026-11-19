//
//  LogoMarqueView.swift
//  Autodex
//
//  Composant SwiftUI d'affichage du logo constructeur avec cache et repli.
//

import SwiftUI

struct LogoMarqueView: View {
    let marque: String
    var taille: CGFloat = 34
    
    var body: some View {
        let nomMarque = marque.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Priorité aux assets locaux de l'application
        if UIImage(named: nomMarque) != nil {
            Image(nomMarque)
                .resizable()
                .scaledToFit()
                .frame(width: taille, height: taille)
        } else if let url = BrandLogoService.shared.urlLogo(pour: marque) {
            // 2. Récupération via le CDN open-source avec cache natif
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: taille, height: taille)
                case .failure:
                    imageSecours
                case .empty:
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: taille, height: taille)
                @unknown default:
                    imageSecours
                }
            }
        } else {
            imageSecours
        }
    }
    
    private var imageSecours: some View {
        Image("voiture")
            .resizable()
            .scaledToFit()
            .frame(width: taille * 0.9, height: taille * 0.9)
    }
}
