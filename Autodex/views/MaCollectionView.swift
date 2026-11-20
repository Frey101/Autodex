//
//  MaCollectionView.swift
//  Autodex
//
//  Created by Tom Tas on 20/11/2026.
//

import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Énumération des Modales Unifiées
enum ActiveSheetCollection: Identifiable {
    case ajoutSpot(image: UIImage, marque: String, modele: String)
    case ficheDetail(car: Car)
    case photoPleinEcran(image: UIImage, titre: String)
    
    var id: String {
        switch self {
        case .ajoutSpot(_, let m, let mo):
            return "ajout_\(m)_\(mo)_\(UUID().uuidString)"
        case .ficheDetail(let car):
            return "fiche_\(car.id.uuidString)"
        case .photoPleinEcran(_, let t):
            return "photo_\(t)_\(UUID().uuidString)"
        }
    }
}

struct MaCollectionView: View {
    var onOuvrirMenu: (() -> Void)? = nil
    
    // Contexte SwiftData et requête ordonnée
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoitureCollection.dateSpotting, order: .reverse) private var voitures: [VoitureCollection]
    
    // État métier et navigation
    @State private var viewModel = CarViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var afficherCamera: Bool = false
    @State private var photoPriseParCamera: UIImage? = nil
    
    // Modale unique pour éviter les conflits SwiftUI
    @State private var sheetActive: ActiveSheetCollection? = nil
    
    // Suppression
    @State private var voitureASupprimer: VoitureCollection? = nil
    @State private var afficherConfirmationSuppression: Bool = false
    
    // Alertes
    @State private var afficherAlerteCameraIndisponible: Bool = false
    @State private var alerteVehiculeNonDetecte: Bool = false
    @State private var messageRejetDetection: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. En-tête Collection
                        VStack(spacing: 6) {
                            Text("Ma Collection")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.indigo)
                            Text("Votre Pokédex personnel des bolides croisés et immortalisés")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        
                        // 2. Statistiques en direct
                        HStack(spacing: 12) {
                            statItem(
                                titre: "Spottés",
                                valeur: "\(voitures.count)",
                                icone: "camera.fill",
                                couleur: .indigo,
                                idAccessibilite: "statSpottesValeur"
                            )
                            statItem(
                                titre: "Marques",
                                valeur: "\(nombreMarquesUniques)",
                                icone: "flag.fill",
                                couleur: .green,
                                idAccessibilite: "statMarquesValeur"
                            )
                            statItem(
                                titre: "Dernier",
                                valeur: dernierSpotMarque,
                                icone: "clock.arrow.circlepath",
                                couleur: .orange,
                                idAccessibilite: "statDernierValeur"
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // 3. Contenu : Liste des Bolides ou État Vide
                        if voitures.isEmpty {
                            etatVideView
                        } else {
                            listeBolidesView
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onOuvrirMenu = onOuvrirMenu {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onOuvrirMenu) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .accessibilityLabel("Ouvrir le menu")
                        .accessibilityIdentifier("boutonMenuCollection")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: ouvrirPrisePhoto) {
                            Label("Prendre une photo", systemImage: "camera")
                        }
                        
                        Button(action: ajouterSpotDemoRapide) {
                            Label("Ajouter un spot démo", systemImage: "sparkles")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.indigo)
                    }
                    .accessibilityLabel("Ajouter un bolide")
                    .accessibilityIdentifier("boutonAjouterSpotToolbar")
                }
            }
            // Détection du choix dans la galerie PhotosUI
            .onChange(of: selectedPhotoItem) { _, newItem in
                traiterPhotoImportee(newItem)
            }
            // Feuille modale unifiée pour l'ajout, la fiche technique ou le plein écran
            .sheet(item: $sheetActive) { activeModal in
                switch activeModal {
                case .ajoutSpot(let image, let marque, let modele):
                    AjoutSpottingSheet(
                        image: image,
                        marqueInitiale: marque,
                        modeleInitial: modele,
                        catalogueSuggestions: viewModel.catalogueLocal,
                        onEnregistrer: { marqueValidee, modeleValide in
                            enregistrerSpot(image: image, marque: marqueValidee, modele: modeleValide)
                        }
                    )
                case .ficheDetail(let car):
                    NavigationStack {
                        CarDetailView(car: car)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Fermer") {
                                        sheetActive = nil
                                    }
                                }
                            }
                    }
                case .photoPleinEcran(let image, let titre):
                    PhotoPleinEcranView(image: image, titre: titre)
                }
            }
            // Caméra UIKit
            .fullScreenCover(isPresented: $afficherCamera) {
                CameraPickerView(image: $photoPriseParCamera)
                    .ignoresSafeArea()
            }
            .onChange(of: photoPriseParCamera) { _, nouvellePhoto in
                if let photo = nouvellePhoto {
                    photoPriseParCamera = nil
                    Task {
                        let resultat = await DetectionVehiculeService.shared.analyserPresenceVehicule(image: photo)
                        await MainActor.run {
                            if resultat.estUnVehicule {
                                sheetActive = .ajoutSpot(image: photo, marque: "", modele: "")
                            } else {
                                messageRejetDetection = resultat.messageExplicatif
                                alerteVehiculeNonDetecte = true
                            }
                        }
                    }
                }
            }
            // Alerte de refus strict si aucun véhicule n'est détecté
            .alert("Aucun véhicule détecté", isPresented: $alerteVehiculeNonDetecte) {
                Button("Compris", role: .cancel) {}
            } message: {
                Text(messageRejetDetection.isEmpty ? "Cette photo ne semble pas contenir de véhicule automobile. Seuls les bolides sont acceptés dans votre collection." : messageRejetDetection)
            }
            // Dialogue de confirmation de suppression
            .confirmationDialog(
                "Supprimer ce véhicule spotté ?",
                isPresented: $afficherConfirmationSuppression,
                titleVisibility: .visible
            ) {
                Button("Supprimer", role: .destructive) {
                    if let voiture = voitureASupprimer {
                        supprimerSpot(voiture)
                    }
                }
                Button("Annuler", role: .cancel) {
                    voitureASupprimer = nil
                }
            } message: {
                if let voiture = voitureASupprimer {
                    Text("La photo et les données de \(voiture.displayName) seront définitivement supprimées du disque.")
                }
            }
            // Alerte si la caméra n'est pas disponible (ex. simulateur)
            .alert("Appareil photo indisponible", isPresented: $afficherAlerteCameraIndisponible) {
                Button("Compris", role: .cancel) {}
            } message: {
                Text("L'appareil photo n'est pas accessible sur le simulateur. Utilisez le bouton Galerie ou Spot Démo pour immortaliser un véhicule.")
            }
        }
        .task {
            // Chargement du catalogue local pour les suggestions et fiches techniques
            if viewModel.catalogueLocal.isEmpty {
                viewModel.chargerCatalogueLocal()
            }
        }
    }
    
    // MARK: - Vue de l'état vide
    private var etatVideView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.12))
                    .frame(width: 86, height: 86)
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 40))
                    .foregroundColor(.indigo)
            }
            
            VStack(spacing: 6) {
                Text("Aucune voiture immortalisée")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Photographiez un bolide croisé dans la rue pour enrichir votre Pokédex automobile.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Actions
            VStack(spacing: 10) {
                Button(action: ouvrirPrisePhoto) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text("Prendre une Photo")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.indigo)
                    .cornerRadius(14)
                    .shadow(color: .indigo.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .accessibilityIdentifier("boutonPrendrePhotoCollection")
                
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Importer depuis la Galerie")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(14)
                }
                .accessibilityIdentifier("boutonImporterPhotoCollection")
                
                Button(action: ajouterSpotDemoRapide) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Ajouter un spot démo (Simulateur)")
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }
                .accessibilityIdentifier("boutonSpotDemoCollection")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Liste des Bolides Spottés
    private var listeBolidesView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Mes Bolides Spottés (\(voitures.count))")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Importer", systemImage: "photo.badge.plus")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                }
                .accessibilityIdentifier("boutonImporterPhotoListe")
            }
            .padding(.horizontal, 18)
            
            LazyVStack(spacing: 14) {
                ForEach(voitures) { voiture in
                    VoitureCollectionCard(
                        voiture: voiture,
                        catalogue: viewModel.catalogueLocal,
                        onVoirPhoto: { image in
                            sheetActive = .photoPleinEcran(image: image, titre: voiture.displayName)
                        },
                        onVoirFiche: { car in
                            sheetActive = .ficheDetail(car: car)
                        },
                        onDemanderSuppression: {
                            voitureASupprimer = voiture
                            afficherConfirmationSuppression = true
                        }
                    )
                    .accessibilityIdentifier("carteVoitureCollection_\(voiture.id.uuidString)")
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Métriques et Statistiques
    private var nombreMarquesUniques: Int {
        Set(voitures.map { $0.make.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }).count
    }
    
    private var dernierSpotMarque: String {
        guard let premier = voitures.first else { return "-" }
        return premier.make.isEmpty ? premier.displayName : premier.make
    }
    
    private func statItem(titre: String, valeur: String, icone: String, couleur: Color, idAccessibilite: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icone)
                .font(.subheadline)
                .foregroundColor(couleur)
            Text(valeur)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .accessibilityIdentifier(idAccessibilite)
            Text(titre)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Actions Métier
    private func ouvrirPrisePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            afficherCamera = true
        } else {
            afficherAlerteCameraIndisponible = true
        }
    }
    
    private func traiterPhotoImportee(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let resultat = await DetectionVehiculeService.shared.analyserPresenceVehicule(image: image)
                await MainActor.run {
                    selectedPhotoItem = nil
                    if resultat.estUnVehicule {
                        sheetActive = .ajoutSpot(image: image, marque: "", modele: "")
                    } else {
                        messageRejetDetection = resultat.messageExplicatif
                        alerteVehiculeNonDetecte = true
                    }
                }
            }
        }
    }
    
    private func ajouterSpotDemoRapide() {
        let modelesDemo: [(marque: String, modele: String)] = [
            ("Porsche", "911 GT3 RS"),
            ("Ferrari", "F40"),
            ("Bugatti", "Chiron"),
            ("Lamborghini", "Countach"),
            ("McLaren", "P1"),
            ("Alpine", "A110 R"),
            ("BMW", "M3 E30")
        ]
        
        let spotChoisi = modelesDemo.randomElement() ?? ("Porsche", "911 GT3 RS")
        let image = CollectionPhotoService.shared.genererImageDemo(
            marque: spotChoisi.marque,
            modele: spotChoisi.modele
        )
        
        sheetActive = .ajoutSpot(image: image, marque: spotChoisi.marque, modele: spotChoisi.modele)
    }
    
    private func enregistrerSpot(image: UIImage, marque: String, modele: String) {
        guard let nomFichier = CollectionPhotoService.shared.sauvegarderPhoto(image) else {
            return
        }
        
        let nouvelleVoiture = VoitureCollection(
            make: marque,
            model: modele,
            photoFileName: nomFichier,
            dateSpotting: Date()
        )
        
        withAnimation {
            modelContext.insert(nouvelleVoiture)
            try? modelContext.save()
        }
    }
    
    private func supprimerSpot(_ voiture: VoitureCollection) {
        withAnimation {
            CollectionPhotoService.shared.supprimerPhoto(nomFichier: voiture.photoFileName)
            modelContext.delete(voiture)
            try? modelContext.save()
            voitureASupprimer = nil
        }
    }
}

// MARK: - Carte d'Affichage d'un Bolide Spotté
struct VoitureCollectionCard: View {
    let voiture: VoitureCollection
    let catalogue: [Car]
    let onVoirPhoto: (UIImage) -> Void
    let onVoirFiche: (Car) -> Void
    let onDemanderSuppression: () -> Void
    
    @State private var imageChargee: UIImage? = nil
    
    private var vehiculeCatalogue: Car? {
        catalogue.first { car in
            let marqueMatch = (car.Make_Name ?? "").lowercased() == voiture.make.lowercased()
            let modeleMatch = (car.Model_Name ?? "").lowercased() == voiture.model.lowercased()
            return marqueMatch && modeleMatch
        } ?? catalogue.first { car in
            (car.Make_Name ?? "").lowercased() == voiture.make.lowercased()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Zone Image avec badge date
            ZStack(alignment: .topTrailing) {
                if let img = imageChargee {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .onTapGesture {
                            onVoirPhoto(img)
                        }
                } else {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .overlay {
                            ProgressView()
                        }
                }
                
                // Badge Date
                Text(voiture.dateAffichee)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(10)
            }
            
            // Zone Informations et Actions
            HStack(alignment: .center, spacing: 12) {
                // Logo Marque
                LogoMarqueView(marque: voiture.make, taille: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(voiture.make)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                        .textCase(.uppercase)
                    
                    Text(voiture.model.isEmpty ? "Modèle non précisé" : voiture.model)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Bouton Fiche technique si correspondance catalogue
                if let car = vehiculeCatalogue {
                    Button(action: { onVoirFiche(car) }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.indigo)
                    }
                    .accessibilityLabel("Fiche technique")
                    .accessibilityIdentifier("boutonFicheSpot_\(voiture.id.uuidString)")
                }
                
                // Bouton Suppression
                Button(action: onDemanderSuppression) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(6)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Supprimer")
                .accessibilityIdentifier("boutonSupprimerSpot_\(voiture.id.uuidString)")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        .task {
            if imageChargee == nil {
                imageChargee = CollectionPhotoService.shared.chargerPhoto(nomFichier: voiture.photoFileName)
            }
        }
    }
}

// MARK: - Feuille Modale d'Ajout d'un Spot
struct AjoutSpottingSheet: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    @State private var marque: String
    @State private var modele: String
    let catalogueSuggestions: [Car]
    let onEnregistrer: (String, String) -> Void
    
    init(image: UIImage, marqueInitiale: String = "", modeleInitial: String = "", catalogueSuggestions: [Car], onEnregistrer: @escaping (String, String) -> Void) {
        self.image = image
        self._marque = State(initialValue: marqueInitiale)
        self._modele = State(initialValue: modeleInitial)
        self.catalogueSuggestions = catalogueSuggestions
        self.onEnregistrer = onEnregistrer
    }
    
    private var estValide: Bool {
        !marque.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Aperçu du bolide") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .clipped()
                        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                }
                
                Section("Identification") {
                    TextField("Marque (ex. Ferrari, Porsche...)", text: $marque)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("champSaisieMarqueSpot")
                    
                    TextField("Modèle (ex. 911 GT3, F40...)", text: $modele)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("champSaisieModeleSpot")
                }
                
                Section {
                    Button(action: {
                        onEnregistrer(marque, modele)
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                            Text("Ajouter à ma collection")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                    }
                    .disabled(!estValide)
                    .listRowBackground(estValide ? Color.indigo : Color.gray.opacity(0.4))
                    .accessibilityIdentifier("boutonValiderSpot")
                }
            }
            .navigationTitle("Nouveau Bolide Spotté")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .accessibilityIdentifier("boutonAnnulerSpot")
                }
            }
        }
    }
}

// MARK: - Visionneuse Photo Plein Écran
struct PhotoPleinEcranView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    let titre: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(titre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Wrapper UIKit UIImagePickerController pour la Caméra
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
