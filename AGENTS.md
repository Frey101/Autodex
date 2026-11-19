# 🚗 Autodex — Mémoire du Projet & Consignes de Développement

Ce document sert de **mémoire centrale**, de **charte de développement** et de **registre de décisions** pour le projet **Autodex**. Tout agent intervenant sur ce dépôt doit impérativement respecter les règles énoncées ci-dessous.

---

## ⚠️ RÈGLE FONDAMENTALE DE GOUVERNANCE (NON-NÉGOCIABLE)

> ### 🛑 L'UTILISATEUR PREND TOUTES LES DÉCISIONS
> **Pour toute ambiguïté, hésitation, choix d'architecture, sélection d'API, refonte d'interface ou orientation produit, l'agent DOIT OBLIGATOIREMENT poser des questions à l'utilisateur et attendre sa décision avant d'agir.**
> 
> - **Ne jamais présumer** d'une préférence utilisateur non spécifiée.
> - **Ne jamais imposer** un choix technique ou fonctionnel sans validation préalable.
> - **Proposer des options structurées** (Avantages / Inconvénients / Recommandation) et laisser le dernier mot à l'utilisateur.

---

## 📌 Présentation du Projet

- **Nom** : Autodex
- **Concept** : Le « Pokédex » automobile sur iOS. Application interactive permettant de découvrir, rechercher et comparer les caractéristiques techniques et les visuels de véhicules et de constructeurs emblématiques.
- **Plateforme cible** : iOS 16.0+ (iPhone & iPad)
- **Langage** : Swift (Swift 5.9+)
- **UI Framework** : SwiftUI
- **Gestion d'état** : `@Observable` (Observation framework)
- **Persistance** : `SwiftData` (Modèle `FavoriteCar`)
- **Outil de développement** : Xcode 16+

---

## 🏗️ Architecture & Organisation du Code

```text
Autodex/
├── AutodexApp.swift          # Point d'entrée de l'application (@main, ModelContainer)
├── model/
│   ├── Car.swift             # Modèle de véhicule (décodage API, specs moteur, consommation)
│   ├── FavoriteCar.swift     # Modèle SwiftData persistant pour les favoris
│   └── Item.swift            # Modèle d'exemple SwiftData initial
├── viewModels/
│   └── CarViewModel.swift    # Logique métier, requêtes réseau asynchrones (async/await, TaskGroup)
├── views/
│   ├── ContentView.swift     # Écran d'accueil (Recherche, Populaires, Liste, Navigationview TabBar)
│   ├── DecouverteView.swift  # Écran de découverte aléatoire / découverte par marque
│   └── CarDetailView.swift   # Fiche technique détaillée du véhicule (Moteur, Dimensions, Efficacité)
└── Assets.xcassets/          # Logos des marques, icônes, couleurs d'accent
```

---

## 🛠️ Règles Techniques & Bonnes Pratiques

1. **Concurrence Swift Moderne** :
   - Privilégier `async/await`, `TaskGroup` et `@MainActor` pour les mises à jour UI.
   - Ne jamais bloquer le thread principal (`MainActor`).

2. **SwiftUI Réactif** :
   - Utiliser `NavigationStack` (plutôt que `NavigationView` déprécié).
   - Gestion des listes avec des identifiants stables dans `ForEach`.
   - Respect des conventions Apple Human Interface Guidelines (espacements dynamiques, typographie système, support Dark/Light mode).

3. **Compilation et Simulateur (Sandbox)** :
   - Le répertoire DerivedData de compilation doit être spécifié dans `/tmp/AutodexBuild` pour respecter l'isolation des processus.
   - Les commandes de build et simulateur s'exécutent avec `xcodebuild` et `xcrun simctl`.
   - Cible simulateur par défaut : iPhone récent (ex. iPhone 17 sous iOS 26.5 / iOS 18+).

4. **Gestion des Données & API (Contrainte 100% Gratuite)** :
   - **Exclusivité Gratuite** : Seules des APIs et sources de données **100 % gratuites** (sans carte bancaire ni frais cachés) doivent être utilisées sur ce projet.
   - Gérer systématiquement les états UI : Chargement (`ProgressView`), Erreur (`errorMessage`), Liste vide (`ContentUnavailableView` ou message d'aide).
   - Les appels réseau doivent être sécurisés avec encodage des paramètres URL.

5. **Stratégie Git & Workflow Professionnel (Git Flow Stricte)** :
   - **Branche `main` (Production / Stabilité)** :
     - Non modifiable directement (aucun commit direct).
     - **Accepte exclusivement les merges provenant de la branche `dev`**.
   - **Branche `dev` (Intégration continue)** :
     - Branche de travail principale pour consolider les développements.
     - Les développements s'effectuent sur des branches secondaires dédiées : `feature/<nom>`, `fix/<nom>`, `refactor/<nom>`.
     - Une fois la fonctionnalité terminée et testée, la branche est mergée sur `dev`.
   - **Exclusions Git obligatoires (.gitignore)** :
     - Les répertoires `.agent/` et `.agents/` sont strictement ignorés par Git.
     - Tout éventuel répertoire `tools/` est obligatoirement ignoré par Git.
     - Les artefacts de build locaux (`DerivedData/`, `build/`, `.DS_Store`) sont ignorés.
   - **Pipeline CI/CD (GitHub Actions)** :
     - Déclenchement automatique sur chaque `push` et `pull_request` ciblant `main` et `dev`.
     - Validation de la compilation Xcode et exécution des tests unitaires (`AutodexTests`).

---

## 📜 Registre des Décisions & Historique

| Date | Domaine | Décision prise / État |
| :--- | :--- | :--- |
| **2026-11-19** | **Orchestration** | Installation du skill `chief-of-staff` pour la coordination stratégique et le suivi des décisions. |
| **2026-11-19** | **Environnement** | Validation du pipeline de compilation et lancement réussi sur Simulateur iOS. |
| **2026-11-19** | **API Données** | Décision utilisateur : utilisation stricte d'APIs **100% gratuites**. Panorama des options gratuites validé (NHTSA, Wikimedia REST, CarQuery, Datasets open source locaux). |
| **2026-11-19** | **Compétences** | Installation de `swiftui-expert` pour les règles de développement et bonnes pratiques Apple HIG. |
| **2026-11-19** | **Git & CI/CD** | Mise en place de la gouvernance Git Flow : `main` réservée aux merges de `dev`, travail par branches, exclusion de `.agent`/`.agents`/`tools`, automatisation CI/CD. |
