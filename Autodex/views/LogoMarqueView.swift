//
//  LogoMarqueView.swift
//  Autodex
//
//  Composant SwiftUI d'affichage du logo constructeur avec mise à l'échelle optimale,
//  remplissage complet du cercle, mise en cache réseau et système de repli.
//

import SwiftUI

struct LogoMarqueView: View {
    let marque: String
    var taille: CGFloat = 48
    
    var body: some View {
        let nomMarque = marque.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        ZStack {
            // Fond blanc épuré pour faire ressortir le logo sans bordure grise opaque
            Circle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            
            // 1. Priorité au logo haute résolution transparent du CDN (avec cache mémoire & disque)
            if let url = BrandLogoService.shared.urlLogo(pour: marque) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1.45)
                            .frame(width: taille, height: taille)
                            .clipShape(Circle())
                    case .failure:
                        vueRepliLocal(nomMarque: nomMarque)
                    case .empty:
                        ProgressView()
                            .scaleEffect(0.6)
                    @unknown default:
                        vueRepliLocal(nomMarque: nomMarque)
                    }
                }
            } else {
                vueRepliLocal(nomMarque: nomMarque)
            }
            
            // Contour discret
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        }
        .frame(width: taille, height: taille)
    }
    
    // MARK: - Repli local (assets du bundle ou image de secours générique)
    @ViewBuilder
    private func vueRepliLocal(nomMarque: String) -> some View {
        if UIImage(named: nomMarque) != nil {
            Image(nomMarque)
                .resizable()
                .scaledToFit()
                .scaleEffect(1.35)
                .frame(width: taille, height: taille)
                .clipShape(Circle())
        } else {
            Image("voiture")
                .resizable()
                .scaledToFit()
                .frame(width: taille * 0.75, height: taille * 0.75)
        }
    }
}
