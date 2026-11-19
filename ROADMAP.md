# 📋 Feuille de Route & Prochaines Étapes — AutoDex

Ce document détaille les prochaines étapes de développement du projet **AutoDex**, conformément aux exigences académiques (BUT Informatique) et aux besoins d'évolution technique et fonctionnelle de l'application.

---

## 📌 Sommaire des Chantiers

1. [Chantier 1 : Widget iOS « La Voiture du Jour » (WidgetKit & App Group)](#-chantier-1--widget-ios--la-voiture-du-jour-)
2. [Chantier 2 : Application Apple Watch « AutoDex Pocket » (watchOS Target)](#-chantier-2--application-apple-watch--autodex-pocket-)
3. [Chantier 3 : Onglet « Ma Collection » (Photo Spotting & Base de Données SwiftData)](#-chantier-3--onglet--ma-collection--photo-spotting--bdd-)
4. [Chantier 4 : Refonte de la Navigation (Menu Hamburger / Tiroir Latéral)](#-chantier-4--refonte-de-la-navigation-menu-hamburger-)
5. [Méthodologie d'Exécution & Git Flow](#-méthodologie-dexécution--git-flow)

---

## 📱 Chantier 1 : Widget iOS « La Voiture du Jour »

### 🎯 Objectif
Fournir un widget natif iOS dynamique sur l'écran d'accueil et de verrouillage, tirant chaque jour un véhicule emblématique du catalogue de 2 157 modèles, avec ouverture directe de sa fiche technique dans l'application (Deep Linking).

### 🛠️ Architecture Technique
- **Framework** : `WidgetKit` + `SwiftUI`.
- **Partage de données (App Group)** :
  - Création de l'identifiant App Group `group.com.dev.autodex.shared`.
  - Partage du dataset local `car_details.json` ou export des données vers `UserDefaults(suiteName:)` / conteneur partagé.
- **Gestion du temps (TimelineProvider)** :
  - `TimelineEntry` : date, heure de validité, véhicule du jour (`Car`), photo mise en cache ou logo.
  - Planification des actualisations chaque jour à minuit (`Timeline(entries: policy: .after)`).
- **Formats supportés** :
  - **`systemSmall`** : Logo constructeur plein format, nom du modèle, puissance en ch et badge énergie.
  - **`systemMedium`** : Photo du véhicule, logo, caractéristiques clés (puissance, transmission, année) et bouton d'action.
  - **`accessoryCircular` / `accessoryRectangular`** (Optionnel) : Complication d'écran verrouillé iOS 16+.
- **Deep Linking** :
  - Utilisation du modificateur `.widgetURL(URL(string: "autodex://car/\(car.id)"))`.
  - Prise en charge dans `AutodexApp.swift` via `.onOpenURL` pour router instantanément l'utilisateur vers la `CarDetailView` correspondante.

### 🧪 Tests & Validation
- Tests unitaires du `TimelineProvider` et de l'algorithme de tirage pseudo-aléatoire basé sur la date du jour (stabilité sur 24h).
- Validation visuelle sur simulateur iPhone 17 (mode sombre / mode clair).

---

## ⌚ Chantier 2 : Application Apple Watch « AutoDex Pocket »

### 🎯 Objectif
Développer une extension watchOS autonome permettant de consulter ses véhicules favoris au poignet, d'explorer des fiches ultra-compactes et de lancer un mini-duel express.

### 🛠️ Architecture Technique
- **Cible Xcode** : Target dédiée watchOS (`AutodexWatch`).
- **Composants partagés** :
  - Partage des modèles `Car.swift` et `FavoriteCar.swift`.
  - Lecture du conteneur `SwiftData` partagé via l'App Group ou synchronisation WatchConnectivity (`WCSession`).
- **Interfaces SwiftUI Watch** :
  - **Vue 1 : Liste des Favoris Défilable** :
    - Navigation fluide optimisée pour la *Digital Crown* (molette rotative).
    - Lignes condensées : mini-logo de marque, nom du modèle et puissance (ch).
  - **Vue 2 : Fiche Technique Compacte** :
    - Photo ou silhouette profilée, specs clés sous forme de badges verticaux : Ch, Carburant, Année.
  - **Vue 3 : Mini-Duel au Poignet** :
    - Bouton rapide pour opposer 2 véhicules aléatoires avec verdict immédiat.
  - **Complication de cadran (Watch Face Complication)** :
    - Jauge circulaire ou texte court indiquant le bolide du jour ou le nombre de favoris enregistrés.

### 🧪 Tests & Validation
- Build et déploiement sur le simulateur Apple Watch Series 10 / Apple Watch Ultra (watchOS 11+).
- Test de la réactivité des interactions Digital Crown et des retours haptiques `WKInterfaceDevice`.

---

## 📸 Chantier 3 : Onglet « Ma Collection » (Photo Spotting & BDD)

### 🎯 Objectif
Transformer l'application en un véritable carnet de bord pour passionnés d'automobile (« Car Spotting »). L'utilisateur peut photographier une voiture de collection dans la rue (ou l'importer de sa galerie), lui attribuer des métadonnées et l'enregistrer dans sa base de données personnelle.

### 🗄️ Modélisation de la Base de Données (SwiftData)
Création d'un nouveau modèle persistant `@Model final class SpotCollectionItem` :

```swift
@Model
final class SpotCollectionItem {
    @Attribute(.unique) var id: UUID
    var dateCapture: Date
    var marque: String
    var modele: String
    var anneeEstimee: Int?
    var commentaire: String?
    var lieuSpot: String?
    
    // Coordonnées GPS facultatives
    var latitude: Double?
    var longitude: Double?
    
    // Stockage optimisé de l'image
    // Privilégier le stockage sur disque avec un nom de fichier relatif
    var cheminPhotoLocale: String
    
    // Liaison facultative avec le catalogue officiel (si le modèle est reconnu)
    var catalogueCarId: String?
}
```

### 🛠️ Fonctionnalités de l'Onglet
1. **Prise de vue & Import** :
   - Déclenchement de l'appareil photo via `AVCaptureSession` / `UIImagePickerController` (avec demande d'autorisation `NSCameraUsageDescription`).
   - Sélection depuis la photothèque via `PhotosPicker` (iOS 16+ PhotosUI).
2. **Formulaire d'Enregistrement** :
   - Saisie rapide de la marque et du modèle (avec suggestion dynamique depuis le catalogue de 2 157 voitures).
   - Ajout de notes personnelles (ex. : « Croisée au rassemblement de Strasbourg »).
   - Géolocalisation automatique du spot (CoreLocation) si autorisée.
3. **Galerie Pokédex de Collection** :
   - Grille adaptative avec vignettes des véhicules spottés, date et lieu.
   - Compteur global : « X bolides dans votre collection ».
   - Fiche détaillée du spot avec photo plein écran et caractéristiques techniques associées.

### 🧪 Tests & Validation
- Tests unitaires CRUD SwiftData : insertion, lecture, mise à jour, suppression d'un spot, intégrité du fichier image local.
- Tests UI de l'ouverture du sélecteur photo et validation de l'enregistrement.

---

## 🧭 Chantier 4 : Refonte de la Navigation (Menu Hamburger)

### 🎯 Objectif
Avec l'ajout de « Ma Collection » et des fonctionnalités existantes (Accueil, Découverte, Duel, Quiz, Favoris), la barre d'onglets inférieure (`TabView`) devient trop chargée (6+ onglets). Il est nécessaire de restructurer la navigation de façon professionnelle et intuitive.

### 📐 Options d'Architecture UI

#### Option A (Recommandée) : Menu Tiroir Latéral (Side Drawer / Hamburger)
- **Barre supérieure (Top Bar)** :
  - Bouton Hamburger (`line.3.horizontal`) en haut à gauche.
  - Titre dynamique de la section active.
  - Raccourci recherche ou profil en haut à droite.
- **Tiroir latéral fluide** :
  - Glissement depuis la gauche (animé ou geste de swipe).
  - En-tête stylisé avec logo AutoDex, statistiques (Nb de favoris, score Quiz, bolides spottés).
  - Navigation vers :
    1. 🏠 **Accueil & Catalogue** (Recherche, filtres, populaires, nouveautés)
    2. 📸 **Ma Collection** (Photos spottées, carnet de bord)
    3. ⚔️ **Mode Duel** (Comparateur face-à-face)
    4. 🎮 **Pokédex Quiz** (Devine la voiture, score, records)
    5. ✨ **Découverte Aléatoire** (Tirage de cartes)
    6. ❤️ **Favoris Persistants** (Sauvegardes SwiftData)
    7. ⚙️ **Paramètres & À propos** (Version, cache, infos BUT)

#### Option B : TabBar Hybride (3 Onglets Principaux + Menu « Plus »)
- 3 onglets fixes en bas : *Accueil*, *Collection*, *Favoris*.
- 4ème onglet : *Arcade / Plus* ouvrant un hub vers le Duel, le Quiz et la Découverte.

---

## 🌿 Méthodologie d'Exécution & Git Flow

Chaque chantier sera conduit selon la rigueur établie :

1. **Branche de travail dédiée** créée depuis `dev` :
   - `feature/navigation-menu-hamburger`
   - `feature/widget-voiture-du-jour`
   - `feature/watch-autodex-pocket`
   - `feature/collection-photo-bdd`
2. **Approche TDD & Tests systématiques** :
   - Écriture préalable des tests unitaires et des tests UI.
   - Vérification de non-régression sur l'ensemble de la suite (84+ tests).
3. **Validation utilisateur** : Présentation des captures d'écran et validation avant merge.
4. **Merge & Publication** :
   - Merge `--no-ff` sur `dev`, push vers `origin/dev`.
   - Synchronisation locale de `main` (aucun push distant automatique sur `main`).
