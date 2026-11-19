//
//  QuizView.swift
//  Autodex
//
//  Created by iutsd-mmi on 04/06/2026.
//

import SwiftUI

struct QuizView: View {
    @State private var viewModel = CarViewModel()
    @State private var questionCourante: QuestionQuiz? = nil
    @State private var indexSelectionne: Int? = nil
    @State private var reponseValidee: Bool = false
    
    // Scores
    @State private var score: Int = 0
    @State private var serie: Int = 0
    @State private var meilleurScore: Int = 0
    
    // Visuel
    @State private var wikiPhotoUrl: String? = nil
    @State private var estEnChargementPhoto: Bool = false
    @State private var indiceRevele: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - En-tête & Barre de Score
                    HStack(spacing: 12) {
                        blocScore(titre: "Score", valeur: "\(score)", couleur: .blue)
                        blocScore(titre: "Série", valeur: "\(serie) 🔥", couleur: .orange)
                        blocScore(titre: "Record", valeur: "\(meilleurScore) 🏆", couleur: .purple)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    if let question = questionCourante {
                        let cible = question.voitureCible
                        
                        // MARK: - Carte Mystère (Silhouette & Photo)
                        VStack(spacing: 14) {
                            Text(reponseValidee ? "C'est bien..." : "Quel est ce véhicule ?")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // Emplacement Photo / Silhouette
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(.systemGray6), Color(.systemGray5)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 190)
                                
                                if let photoUrl = wikiPhotoUrl, let url = URL(string: photoUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            VStack(spacing: 8) {
                                                ProgressView()
                                                Text("Chargement du visuel...")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 190)
                                                .clipped()
                                                .cornerRadius(18)
                                                // Effet Silhouette : contrasté et désaturé sans devenir un rectangle noir opaque
                                                .grayscale(reponseValidee ? 0.0 : 0.9)
                                                .brightness(reponseValidee ? 0.0 : -0.35)
                                                .contrast(reponseValidee ? 1.0 : 2.2)
                                                .blur(radius: reponseValidee ? 0 : 2.5)
                                                .animation(.spring(response: 0.4), value: reponseValidee)
                                        case .failure:
                                            vueSilhouetteSecours(marque: cible.Make_Name, resolu: reponseValidee)
                                        @unknown default:
                                            vueSilhouetteSecours(marque: cible.Make_Name, resolu: reponseValidee)
                                        }
                                    }
                                } else if estEnChargementPhoto {
                                    VStack(spacing: 8) {
                                        ProgressView()
                                        Text("Recherche du visuel...")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    vueSilhouetteSecours(marque: cible.Make_Name, resolu: reponseValidee)
                                }
                                
                                // Badge discret "Mystère" dans le coin supérieur sans masquer la silhouette
                                if !reponseValidee {
                                    VStack {
                                        HStack {
                                            HStack(spacing: 4) {
                                                Image(systemName: "questionmark.circle.fill")
                                                    .font(.caption)
                                                Text("Silhouette Mystère")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.black.opacity(0.65))
                                            .clipShape(Capsule())
                                            .padding(10)
                                            
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .frame(height: 190)
                            
                            // Révélation du nom après validation
                            if reponseValidee {
                                VStack(spacing: 4) {
                                    Text(cible.displayName)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                        .transition(.scale.combined(with: .opacity))
                                    
                                    Text(cible.displaySubtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Indices (Année & Puissance)
                            HStack(spacing: 8) {
                                if indiceRevele || reponseValidee {
                                    if let annee = cible.year {
                                        badgeIndice(texte: "Année : \(annee)", icone: "calendar")
                                    }
                                    if let hp = cible.horsepower {
                                        badgeIndice(texte: "Puissance : \(hp) ch", icone: "bolt.fill")
                                    }
                                } else {
                                    Button(action: {
                                        withAnimation { indiceRevele = true }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "lightbulb.fill")
                                            Text("Dévoiler un indice")
                                        }
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.orange.opacity(0.12))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 16)
                        
                        // MARK: - Les 4 Propositions (QCM)
                        VStack(spacing: 10) {
                            ForEach(Array(question.propositions.enumerated()), id: \.offset) { index, proposition in
                                boutonProposition(
                                    texte: proposition.displayName,
                                    index: index,
                                    bonneReponseIndex: question.bonneReponseIndex
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Bouton Véhicule Suivant
                        if reponseValidee {
                            Button(action: passerQuestionSuivante) {
                                HStack(spacing: 8) {
                                    Text("Véhicule Suivant")
                                        .font(.headline)
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .cornerRadius(16)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 6)
                            .accessibilityIdentifier("boutonQuestionSuivanteQuiz")
                        }
                    } else {
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("Préparation du Quiz Pokédex...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 250)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Pokédex Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .task {
                if questionCourante == nil {
                    genererNouvelleQuestion()
                }
            }
        }
    }
    
    // MARK: - Bouton de Proposition QCM
    @ViewBuilder
    private func boutonProposition(texte: String, index: Int, bonneReponseIndex: Int) -> some View {
        let estSelectionne = indexSelectionne == index
        let estBonneReponse = index == bonneReponseIndex
        
        let couleurBordure: Color = {
            guard reponseValidee else { return Color.clear }
            if estBonneReponse { return .green }
            if estSelectionne && !estBonneReponse { return .red }
            return Color.clear
        }()
        
        let couleurFond: Color = {
            guard reponseValidee else { return Color.white }
            if estBonneReponse { return Color.green.opacity(0.12) }
            if estSelectionne && !estBonneReponse { return Color.red.opacity(0.12) }
            return Color.white
        }()
        
        Button(action: {
            selectionnerReponse(index: index)
        }) {
            HStack {
                Text(texte)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(reponseValidee && estBonneReponse ? .green : .primary)
                
                Spacer()
                
                if reponseValidee {
                    if estBonneReponse {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if estSelectionne {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(couleurFond)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(couleurBordure, lineWidth: 2)
            )
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        }
        .disabled(reponseValidee)
        .accessibilityIdentifier("propositionQuiz_\(index)")
    }
    
    // MARK: - Composants Visuels
    private func blocScore(titre: String, valeur: String, couleur: Color) -> some View {
        VStack(spacing: 4) {
            Text(titre)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(valeur)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(couleur)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    private func badgeIndice(texte: String, icone: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icone)
                .foregroundColor(.orange)
            Text(texte)
                .foregroundColor(.primary)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private func vueSilhouetteSecours(marque: String?, resolu: Bool) -> some View {
        ZStack {
            LinearGradient(
                colors: resolu
                    ? [Color.blue.opacity(0.12), Color.purple.opacity(0.08)]
                    : [Color(red: 28/255, green: 32/255, blue: 44/255), Color(red: 18/255, green: 20/255, blue: 28/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            if resolu, let marque = marque {
                VStack(spacing: 8) {
                    LogoMarqueView(marque: marque, taille: 70)
                    Text(marque)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: .cyan.opacity(0.4), radius: 8, x: 0, y: 3)
                    Text("Profil Silhouette Aérodynamique")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .frame(height: 190)
        .cornerRadius(18)
    }
    
    // MARK: - Logique Métier du Quiz
    private func selectionnerReponse(index: Int) {
        guard !reponseValidee, let question = questionCourante else { return }
        
        indexSelectionne = index
        reponseValidee = true
        
        let estCorrect = index == question.bonneReponseIndex
        
        if estCorrect {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            score += 1
            serie += 1
            if score > meilleurScore {
                meilleurScore = score
            }
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            serie = 0
        }
    }
    
    private func passerQuestionSuivante() {
        genererNouvelleQuestion()
    }
    
    private func genererNouvelleQuestion() {
        indexSelectionne = nil
        reponseValidee = false
        indiceRevele = false
        wikiPhotoUrl = nil
        
        guard let nouvelleQuestion = viewModel.genererQuestionQuiz() else { return }
        self.questionCourante = nouvelleQuestion
        
        // Charger la photo de la voiture cible
        let cible = nouvelleQuestion.voitureCible
        if let marque = cible.Make_Name, let modele = cible.Model_Name {
            estEnChargementPhoto = true
            Task {
                let detail = await WikipediaService.shared.chargerInfosVehicule(marque: marque, modele: modele)
                if questionCourante?.id == nouvelleQuestion.id {
                    wikiPhotoUrl = detail?.photoUrl
                    estEnChargementPhoto = false
                }
            }
        }
    }
}
