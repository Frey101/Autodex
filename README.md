# 🚗 Autodex

**Autodex** est une application iOS interactive conçue comme le « Pokédex » de l'automobile. Elle permet de rechercher, découvrir et consulter les caractéristiques techniques de plus de 2 150 véhicules et constructeurs emblématiques.

---

## 🚀 Fonctionnalités

- **Catalogue local complet** : Plus de 2 150 modèles indexés en local (données 100 % gratuites et disponibles hors-ligne).
- **Spécifications techniques détaillées** : Moteur, puissance (ch), transmission, carrosserie et années de production.
- **Photos réelles & Histoire Wikipédia** : Récupération dynamique et gratuite des visuels haute résolution et des résumés historiques via l'API REST de Wikipédia (nettoyage intelligent des noms de modèles, filtre strict anti-logos/pages constructeurs et repli sur la base anglophone).
- **Logos officiels en plein cercle** : Récupération haute résolution transparente, mise à l'échelle optique plein format occupant 100 % du cercle sans marges parasites, et cache persistant (RAM + disque).
- **Mode Découverte Pokédex enrichi** : Tirage de cartes interactives avec vraie photo du véhicule, badges de specs (année, puissance ch, carburant), gestes de glissement (passer/favori) et consultation directe de la fiche technique.
- **Pagination fluide par 20 éléments** : Chargement progressif par tranches de 20 véhicules sur les onglets Populaires, Nouveautés et la recherche, défilement infini automatique et bouton manuel « Afficher plus de véhicules ».
- **Onglet Nouveautés (sorties récentes)** : Filtrage strict des modèles sortis ces 6 derniers mois (millésimes 2025 et 2026 : Ferrari F80, Bugatti Tourbillon, McLaren W1, Porsche Macan Turbo Electric, Audi SQ6 e-tron, BMW i5 M60, Renault 5 E-Tech, Alpine A290, etc.).
- **Recherche dynamique en temps réel** : Filtrage instantané dès la frappe et lors de l'effacement de caractères, restauration automatique des modèles populaires et bouton d'effacement rapide.
- **Véhicules populaires & Nouveautés** : Sélecteur d'onglets ergonomique en en-tête d'accueil.
- **Fiches véhicules** : Vue détaillée avec caractéristiques moteur, dimensions, photos et logos des marques.
- **Favoris persistants & navigables** : Sauvegarde locale des modèles préférés via SwiftData, affichage des spécifications et ouverture directe de la fiche technique en un tap.

---

## 🛠️ Stack Technique

- **Langage** : Swift (Swift 5.9+)
- **Interface** : SwiftUI (iOS 16+)
- **Gestion d'état** : Framework Observation (`@Observable`)
- **Persistance** : SwiftData
- **Concurrence** : `async/await`, `TaskGroup`, `@MainActor`
- **Tests** : XCTest (tests unitaires décodage, mapping et recherche)
- **Données** : Dataset local embarqué (`car_details.json`) + API NHTSA vPIC

---

## 📂 Organisation du Code

```text
Autodex/
├── AutodexApp.swift          # Point d'entrée de l'application (@main, ModelContainer)
├── model/
│   ├── Car.swift             # Modèle Car, spécifications moteurs et décodage
│   └── FavoriteCar.swift     # Modèle persistant SwiftData pour les favoris
├── viewModels/
│   └── CarViewModel.swift    # Logique métier, catalogue local et recherche asynchrone
├── services/
│   ├── WikipediaService.swift # Service asynchrone Wikipédia (photos, résumés, cache)
│   └── BrandLogoService.swift # Service de logos constructeurs et normalisation
├── views/
│   ├── ContentView.swift      # Écran d'accueil (Recherche, Populaires, Liste)
│   ├── DecouverteView.swift   # Écran de découverte aléatoire et par marque
│   ├── CarDetailView.swift    # Fiche technique détaillée (Moteur, transmission, dimensions)
│   └── LogoMarqueView.swift   # Composant d'affichage de logo avec cache et repli
├── car_details.json          # Dataset local de 2 157 véhicules avec specs moteurs
└── Assets.xcassets/          # Logos des marques, visuels et icônes
```

---

## 🔧 Installation & Lancement

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/Frey101/Autodex.git
   cd Autodex
   ```

2. **Ouvrir le projet dans Xcode** :
   ```bash
   open Autodex.xcodeproj
   ```

3. **Lancer les tests unitaires en ligne de commande** :
   ```bash
   xcodebuild test -project Autodex.xcodeproj -scheme Autodex -destination "platform=iOS Simulator,name=iPhone 17"
   ```

---

## 🌿 Gestion Git

Le projet suit un **Git Flow** strict :
- `main` : Branche stable de production (merges stricts depuis `dev`).
- `dev` : Branche d'intégration continue des fonctionnalités validées.
- `feature/*` : Branches de travail isolées pour chaque nouvelle fonctionnalité.
