//
//  WikipediaService.swift
//  Autodex
//
//  Service d'accès à l'API REST publique et gratuite de Wikipédia
//  pour récupérer les photos réelles et résumés historiques des véhicules.
//  Intègre un algorithme anti-faux-positifs pour éliminer les logos et pages constructeurs.
//

import Foundation

// MARK: - Modèles de décodage Wikipédia REST
struct WikipediaSummaryResponse: Codable {
    let title: String?
    let extract: String?
    let description: String?
    let thumbnail: WikipediaImageInfo?
    let originalimage: WikipediaImageInfo?
    let content_urls: WikipediaContentUrls?
}

struct WikipediaImageInfo: Codable {
    let source: String
    let width: Int?
    let height: Int?
}

struct WikipediaContentUrls: Codable {
    let mobile: WikipediaUrlDetail?
    let desktop: WikipediaUrlDetail?
}

struct WikipediaUrlDetail: Codable {
    let page: String?
}

// MARK: - Modèles de décodage de recherche MediaWiki
struct WikipediaSearchResponse: Codable {
    let query: WikipediaSearchQuery?
}

struct WikipediaSearchQuery: Codable {
    let search: [WikipediaSearchResultItem]?
}

struct WikipediaSearchResultItem: Codable {
    let title: String
}

// MARK: - Résultat simplifié pour l'application
struct DetailWikipedia: Sendable, Equatable {
    let titre: String
    let resume: String?
    let photoUrl: String?
    let pageUrl: String?
}

// MARK: - Acteur Asynchrone Wikipédia (Gestion Concurrente et Cache)
actor WikipediaService {
    static let shared = WikipediaService()
    
    // Cache en mémoire pour éviter les requêtes réseau redondantes
    private var cache: [String: DetailWikipedia] = [:]
    
    // User-Agent explicite conformément à la politique d'utilisation de l'API Wikimedia
    private let userAgent = "AutodexApp/1.0 (iOS; Student Project; BUT Informatique; contact@autodex.local)"
    
    // MARK: - Récupération principale des informations d'un véhicule
    func chargerInfosVehicule(marque: String, modele: String) async -> DetailWikipedia? {
        let cleCache = "\(marque.lowercased())_\(modele.lowercased())"
        if let enCache = cache[cleCache] {
            return enCache
        }
        
        let marquePropre = marque.trimmingCharacters(in: .whitespacesAndNewlines)
        let variantes = genererVariantesRecherche(marque: marquePropre, modele: modele)
        
        var resumeFrTrouve: DetailWikipedia? = nil
        var photoEnTrouvee: String? = nil
        
        // --- ÉTAPE 1 : Recherche en Français (Texte historique et photo FR) ---
        for variante in variantes {
            // 1.1 Requête directe FR
            if let directFr = await recupererResumeDirect(langue: "fr", titre: variante, marque: marquePropre) {
                if directFr.photoUrl != nil {
                    cache[cleCache] = directFr
                    return directFr
                }
                if directFr.resume != nil && resumeFrTrouve == nil {
                    resumeFrTrouve = directFr
                }
            }
            
            // 1.2 Recherche MediaWiki FR ciblée
            let requeteSearchFr = "\(variante) automobile"
            if let titreSearchFr = await rechercherTitreValide(langue: "fr", requete: requeteSearchFr, marque: marquePropre, modele: modele) {
                if let detailSearchFr = await recupererResumeDirect(langue: "fr", titre: titreSearchFr, marque: marquePropre) {
                    if detailSearchFr.photoUrl != nil {
                        cache[cleCache] = detailSearchFr
                        return detailSearchFr
                    }
                    if detailSearchFr.resume != nil && resumeFrTrouve == nil {
                        resumeFrTrouve = detailSearchFr
                    }
                }
            }
        }
        
        // --- ÉTAPE 2 : Recherche en Anglais (Base mondiale très complète pour les photos) ---
        for variante in variantes {
            // 2.1 Requête directe EN
            if let directEn = await recupererResumeDirect(langue: "en", titre: variante, marque: marquePropre) {
                if let photo = directEn.photoUrl {
                    photoEnTrouvee = photo
                    break
                }
            }
            
            // 2.2 Recherche MediaWiki EN ciblée
            let requeteSearchEn = "\(variante) car"
            if let titreSearchEn = await rechercherTitreValide(langue: "en", requete: requeteSearchEn, marque: marquePropre, modele: modele) {
                if let detailSearchEn = await recupererResumeDirect(langue: "en", titre: titreSearchEn, marque: marquePropre) {
                    if let photo = detailSearchEn.photoUrl {
                        photoEnTrouvee = photo
                        break
                    }
                }
            }
        }
        
        // --- ÉTAPE 3 : Synthèse intelligente (Résumé FR + Meilleure Photo EN/FR) ---
        let photoFinale = photoEnTrouvee ?? resumeFrTrouve?.photoUrl
        let resumeFinal = resumeFrTrouve?.resume
        let pageUrlFinale = resumeFrTrouve?.pageUrl
        let titreFinal = resumeFrTrouve?.titre ?? "\(marquePropre) \(modele)"
        
        if photoFinale != nil || resumeFinal != nil {
            let resultat = DetailWikipedia(
                titre: titreFinal,
                resume: resumeFinal,
                photoUrl: photoFinale,
                pageUrl: pageUrlFinale
            )
            cache[cleCache] = resultat
            return resultat
        }
        
        return nil
    }
    
    // MARK: - Génération des variantes de nettoyage de titre
    private func genererVariantesRecherche(marque: String, modele: String) -> [String] {
        var variantes: [String] = []
        let modeleNettoye = modele.replacingOccurrences(of: "\\s*\\(.*?\\)", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Marque + Modèle nettoyé (sans parenthèses)
        variantes.append("\(marque) \(modeleNettoye)")
        
        // 2. Marque + Premier terme significatif du modèle si composé
        let mots = modeleNettoye.split(separator: " ").map(String.init)
        if mots.count > 1 {
            variantes.append("\(marque) \(mots[0])")
            if mots.count > 2 {
                variantes.append("\(marque) \(mots[0]) \(mots[1])")
            }
        }
        
        // 3. Modèle brut seul (pour les voitures déjà préfixées ou uniques)
        if !variantes.contains(modeleNettoye) && !modeleNettoye.lowercased().hasPrefix(marque.lowercased()) {
            variantes.append(modeleNettoye)
        }
        
        return variantes
    }
    
    // MARK: - Validation et filtrage anti-faux-positifs d'une image
    private func estImageValide(url: String?) -> Bool {
        guard let url = url?.lowercased(), !url.isEmpty else { return false }
        
        // Rejet des logos vectoriels SVG et des fichiers explicites de logos
        if url.hasSuffix(".svg") { return false }
        
        let motsExclus = [
            "logo", "emblem", "badge", "blason", "coat_of_arms", "symbol",
            "marque", "icon", "placeholder", "diagram", "flag", "carte",
            "schema", "dessin", "silhouette"
        ]
        
        return !motsExclus.contains(where: { url.contains($0) })
    }
    
    // MARK: - Validation d'un article Wikipédia (élimination des pages constructeurs)
    private func estArticleVehiculeValide(summary: WikipediaSummaryResponse, marque: String) -> Bool {
        guard let title = summary.title?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        
        // Si le titre de la page est strictement le nom du constructeur, c'est la société et non un véhicule !
        if title.lowercased() == marque.lowercased() {
            return false
        }
        
        let description = summary.description?.lowercased() ?? ""
        let extract = summary.extract?.lowercased() ?? ""
        
        // Rejet des pages d'entreprises, homonymies ou personnes
        let motsEntreprise = ["constructeur", "entreprise", "société", "homonymie", "filiale", "groupe automobile", "personnalité", "ingénieur"]
        if motsEntreprise.contains(where: { description.contains($0) }) {
            // Exception : si l'extrait confirme explicitement qu'il s'agit d'un véhicule/modèle
            let estModele = extract.contains("automobile") || extract.contains("voiture") || extract.contains("modèle") || extract.contains("véhicule")
            if !estModele {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Requête REST directe sur le endpoint de résumé
    private func recupererResumeDirect(langue: String, titre: String, marque: String) async -> DetailWikipedia? {
        let titreFormatte = titre.replacingOccurrences(of: " ", with: "_")
        guard let titreEncode = titreFormatte.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        let urlString = "https://\(langue).wikipedia.org/api/rest_v1/page/summary/\(titreEncode)"
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 7.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            let summary = try JSONDecoder().decode(WikipediaSummaryResponse.self, from: data)
            
            // Vérification de la pertinence de la page
            guard estArticleVehiculeValide(summary: summary, marque: marque) else {
                return nil
            }
            
            // Sélection et validation de l'image (l'image originale ou la vignette)
            let photoCandidate = summary.originalimage?.source ?? summary.thumbnail?.source
            let photo = estImageValide(url: photoCandidate) ? photoCandidate : nil
            
            let resume = summary.extract
            let page = summary.content_urls?.mobile?.page ?? summary.content_urls?.desktop?.page
            
            return DetailWikipedia(
                titre: summary.title ?? titre,
                resume: resume,
                photoUrl: photo,
                pageUrl: page
            )
        } catch {
            return nil
        }
    }
    
    // MARK: - Recherche MediaWiki avec sélection stricte du titre
    private func rechercherTitreValide(langue: String, requete: String, marque: String, modele: String) async -> String? {
        guard let requeteEncode = requete.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let urlString = "https://\(langue).wikipedia.org/w/api.php?action=query&list=search&srsearch=\(requeteEncode)&format=json&utf8=1"
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 7.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            let searchResult = try JSONDecoder().decode(WikipediaSearchResponse.self, from: data)
            guard let elements = searchResult.query?.search, !elements.isEmpty else {
                return nil
            }
            
            let marqueLower = marque.lowercased()
            let motsModele = modele.replacingOccurrences(of: "(", with: " ")
                                   .replacingOccurrences(of: ")", with: " ")
                                   .lowercased()
                                   .split(separator: " ")
                                   .map(String.init)
                                   .filter { $0.count >= 2 }
            
            // Parcours des premiers résultats pour choisir le plus pertinent
            for item in elements.prefix(5) {
                let title = item.title
                let titleLower = title.lowercased()
                
                // Rejet si c'est seulement la marque
                if titleLower == marqueLower { continue }
                if titleLower.contains("homonymie") || titleLower.contains("liste de") { continue }
                
                let contientMarque = titleLower.contains(marqueLower)
                let contientMotCleModele = motsModele.contains(where: { titleLower.contains($0) })
                
                if contientMarque && contientMotCleModele {
                    return title
                }
            }
            
            // Deuxième essai assoupli : le premier élément contenant le nom de marque
            for item in elements.prefix(3) {
                let titleLower = item.title.lowercased()
                if titleLower != marqueLower && titleLower.contains(marqueLower) && !titleLower.contains("homonymie") {
                    return item.title
                }
            }
            
            return nil
        } catch {
            return nil
        }
    }
}
