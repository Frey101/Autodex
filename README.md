# 🚗 Autodex

**Autodex** est une application iOS interactive conçue comme le « Pokédex » de l'automobile. Elle permet de rechercher, découvrir et consulter les caractéristiques techniques de plus de 2 100 véhicules et constructeurs emblématiques.

---

## 🚀 Fonctionnalités

- **Catalogue local complet** : Plus de 2 100 modèles indexés en local (données 100 % gratuites et disponibles hors-ligne).
- **Spécifications techniques détaillées** : Moteur, puissance (ch), transmission, carrosserie et années de production.
- **Photos réelles & Histoire Wikipédia** : Récupération dynamique et gratuite des visuels haute résolution et des résumés historiques via l'API REST de Wikipédia (avec cache mémoire).
- **Logos officiels & Échelle optimisée** : Récupération dynamique haute résolution, mise à l'échelle optique harmonisée (48x48) et mise en cache persistant (RAM + disque) avec `LogoMarqueView`.
- **Recherche dynamique en temps réel** : Filtrage instantané dès la frappe et lors de l'effacement de caractères, restauration automatique des modèles populaires et bouton d'effacement rapide.
- **Véhicules populaires** : Sélection dynamique et équilibrée de modèles emblématiques sur la page d'accueil.
- **Fiches véhicules** : Vue détaillée avec caractéristiques moteur, dimensions, photos et logos des marques.
- **Favoris persistants** : Sauvegarde locale des modèles préférés via SwiftData.

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
├── car_details.json          # Dataset local de 2 110 véhicules avec specs moteurs
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
