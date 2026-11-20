# 🚗 Autodex

**Autodex** est une application iOS interactive conçue comme le « Pokédex » de l'automobile. Elle permet de rechercher, découvrir et consulter les caractéristiques techniques de plus de 2 150 véhicules et constructeurs emblématiques.

---

## 🚀 Fonctionnalités

- **Authentification Firebase (100% Gratuite)** : Accès sécurisé avant d'entrer dans l'application avec le SDK officiel Firebase Auth (sans compte Apple payant). Support de l'inscription/connexion par Email & Mot de passe, de la connexion rapide avec Google (Gmail), de la réinitialisation de mot de passe par email, de la gestion de session persistante et de la déconnexion directe depuis le menu tiroir latéral.
- **Catalogue local complet** : Plus de 2 150 modèles indexés en local (données 100 % gratuites et disponibles hors-ligne).
- **Spécifications techniques détaillées** : Moteur, puissance (ch), transmission, carrosserie et années de production.
- **Photos réelles & Histoire Wikipédia** : Récupération dynamique et gratuite des visuels haute résolution et des résumés historiques via l'API REST de Wikipédia (nettoyage intelligent des noms de modèles, filtre strict anti-logos/pages constructeurs et repli sur la base anglophone).
- **Logos officiels en plein cercle** : Récupération haute résolution transparente, mise à l'échelle optique plein format occupant 100 % du cercle sans marges parasites, et cache persistant (RAM + disque).
- **Navigation ergonomique par Menu Tiroir (Hamburger)** : Remplacement de l'ancienne TabBar saturée par un menu latéral fluide accessible depuis chaque écran (bouton dédié et glissement tactile), regroupant 7 sections claires (Accueil, Ma Collection, Mode Duel, Quiz, Découverte, Favoris, À Propos) avec compteurs en temps réel (2 157 véhicules, favoris) et fond assombrissant interactif.
- **Section « Ma Collection » & Contrôle IA Vision** : Carnet de bord personnel permettant d'immortaliser des bolides croisés dans la rue via l'appareil photo ou la galerie, avec contrôle strict par IA locale (framework Apple Vision) rejetant automatiquement les photos sans véhicule automobile, sauvegarde optimisée des fichiers JPEG sur disque local (`Documents/PhotosCollection/`), modèle persistant SwiftData (`VoitureCollection`), statistiques en direct, visionneuse plein écran et lien direct vers la fiche technique.
- **Fiche « À Propos »** : Présentation du cadre académique BUT Informatique, de l'architecture technique moderne (SwiftUI, Observation, SwiftData, async/await) et des métriques du catalogue.
- **Mode Découverte Pokédex enrichi** : Tirage de cartes interactives avec vraie photo du véhicule, badges de specs (année, puissance ch, carburant), gestes de glissement (passer/favori) et consultation directe de la fiche technique.
- **Pagination fluide par 20 éléments** : Chargement progressif par tranches de 20 véhicules sur les onglets Populaires, Nouveautés et la recherche, défilement infini automatique et bouton manuel « Afficher plus de véhicules ».
- **Onglet Nouveautés (sorties récentes)** : Filtrage strict des modèles sortis ces 6 derniers mois (millésimes 2025 et 2026 : Ferrari F80, Bugatti Tourbillon, McLaren W1, Porsche Macan Turbo Electric, Audi SQ6 e-tron, BMW i5 M60, Renault 5 E-Tech, Alpine A290, etc.).
- **Recherche dynamique & Filtres avancés** : Filtrage instantané dès la frappe et lors de l'effacement de caractères, avec puces de filtres rapides par énergie (Électrique, Hybride, Essence, Diesel) et par puissance (> 300 ch, > 500 ch) tout en préservant la pagination.
- **Bouton Like réactif sur Fiche Technique** : Sauvegarde/retrait en favoris directement depuis la barre d'outils de la fiche détaillée, avec retour haptique et persistance SwiftData synchronisée en temps réel.
- **Comparateur Face-à-Face (Mode Duel / Pokédex)** : Comparatif visuel côte à côte de deux véhicules au choix ou en tirage aléatoire (puissance ch, cylindrée, consommation autoroute, année, énergie, transmission) avec décompte de points, couronne et mise en valeur verte sur les caractéristiques gagnantes.
- **Mini-jeu Pokédex « Devine la Voiture »** : Quiz interactif affichant la silhouette assombrie et floutée d'un véhicule mystère, des indices techniques déblocables, 4 choix multiples, retour haptique et suivi du score, de la série de victoires et du record.
- **Widget iOS « La Voiture du Jour » (WidgetKit)** : Extension d'écran d'accueil disponible en formats Petit (`.systemSmall`) et Moyen (`.systemMedium`), avec sélection déterministe quotidienne à minuit parmi 31 supercars emblématiques, synchronisation App Group et Deep Linking direct ouvrant instantanément la fiche technique du bolide.
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
- **Authentification & Cloud** : Firebase Authentication iOS SDK (`FirebaseAuth`, 100% gratuit) & `GoogleSignIn`
- **Tests** : XCTest (120 tests unitaires complets et 17 tests d'interface UI automatisés — 137 tests au total)
- **Vision & IA locale** : Apple Vision framework (`VNClassifyImageRequest`, 100 % gratuit et on-device)
- **Widgets** : WidgetKit (Extension iOS « La Voiture du Jour » + App Group)
- **Données** : Dataset local embarqué (`car_details.json`) + API NHTSA vPIC

---

## 📂 Organisation du Code

```text
Autodex/
├── AutodexApp.swift          # Point d'entrée (@main, AppDelegate Firebase, ModelContainer et porte d'authentification)
├── GoogleService-Info.plist  # Configuration du projet Firebase (Bundle ID: com.iutstdie.autodex)
├── model/
│   ├── Car.swift             # Modèle Car, spécifications moteurs et décodage
│   ├── FavoriteCar.swift     # Modèle persistant SwiftData pour les favoris
│   ├── VoitureCollection.swift # Modèle persistant SwiftData pour les bolides spottés
│   └── UtilisateurAutodex.swift # Modèle utilisateur et fournisseur d'authentification
├── viewModels/
│   └── CarViewModel.swift    # Logique métier, catalogue local et recherche asynchrone
├── services/
│   ├── AuthService.swift     # Service d'authentification Firebase (Email/Mdp, Google, session, erreurs)
│   ├── DetectionVehiculeService.swift # Détection et contrôle strict par IA Vision de la présence d'un véhicule
│   ├── CollectionPhotoService.swift # Gestionnaire de photos spottées sur disque local (JPEG, cache, démo)
│   ├── VoitureDuJourService.swift # Service déterministe Voiture du Jour, Deep Link et App Group
│   ├── WikipediaService.swift # Service asynchrone Wikipédia (photos, résumés, cache)
│   └── BrandLogoService.swift # Service de logos constructeurs et normalisation
└── views/
    ├── AuthentificationView.swift # Écran de connexion, inscription, mot de passe oublié et Google
    ├── ContentView.swift     # Accueil, catalogue, recherche et navigation
    ├── MenuTiroirView.swift  # Menu tiroir latéral, profil utilisateur et déconnexion
├── views/
│   ├── ContentView.swift      # Écran d'accueil et coordinateur Navigationview avec Menu Tiroir
│   ├── MenuTiroirView.swift   # Menu latéral coulissant (7 sections, compteurs et badges)
│   ├── MaCollectionView.swift # Carnet de bord et car spotting avec statistiques
│   ├── DecouverteView.swift   # Écran de découverte aléatoire et par marque
│   ├── ComparateurView.swift  # Comparateur face-à-face (Duel Pokédex avec specs et gagnant)
│   ├── QuizView.swift         # Mini-jeu Pokédex « Devine la Voiture » (Silhouette et QCM)
│   ├── FavorisView.swift      # Écran dédié aux véhicules favoris persistants
│   ├── AProposView.swift      # Fiche académique BUT Informatique et architecture
│   ├── CarDetailView.swift    # Fiche technique détaillée (Like Toolbar, Moteur, Dimensions)
│   └── LogoMarqueView.swift   # Composant d'affichage de logo avec cache et repli
├── car_details.json          # Dataset local de 2 157 véhicules avec specs moteurs
└── Assets.xcassets/          # Logos des marques, visuels et icônes

AutodexWidget/                # Cible App Extension WidgetKit iOS
├── AutodexWidgetBundle.swift # Point d'entrée du bundle de widgets (@main)
├── VoitureDuJourWidget.swift # Définition du Widget (formats .systemSmall & .systemMedium)
├── VoitureDuJourProvider.swift # TimelineProvider (renouvellement quotidien à minuit)
├── VoitureDuJourWidgetView.swift # Vues SwiftUI des formats Petit et Moyen
└── VoitureDuJourModel.swift  # Modèle autonome et moteur de sélection hors-ligne
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
