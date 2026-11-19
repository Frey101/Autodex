//
//  WikipediaService.swift
//  Autodex
//
//  Service d'accès à l'API REST publique et gratuite de Wikipédia
//  pour récupérer les photos et résumés historiques des véhicules.
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
    
    // Récupère les données d'un véhicule avec système de repli (FR direct -> FR recherche -> EN)
    func chargerInfosVehicule(marque: String, modele: String) async -> DetailWikipedia? {
        let cleCache = "\(marque.lowercased())_\(modele.lowercased())"
        if let enCache = cache[cleCache] {
            return enCache
        }
        
        // Nettoyage des chaînes de requête
        let marquePropre = marque.trimmingCharacters(in: .whitespacesAndNewlines)
        let modelePropre = modele.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Essai direct sur Wikipédia en Français (ex: "Peugeot 508", "Porsche 911")
        let requeteDirecte = "\(marquePropre) \(modelePropre)"
        if let detail = await recupererResumeDirect(langue: "fr", titre: requeteDirecte) {
            if detail.photoUrl != nil || detail.resume != nil {
                cache[cleCache] = detail
                return detail
            }
        }
        
        // 2. Recherche MediaWiki FR pour trouver le titre exact de l'article automobile
        var titreTrouve = await rechercherTitreArticle(langue: "fr", requete: "\(marquePropre) \(modelePropre) automobile")
        if titreTrouve == nil {
            titreTrouve = await rechercherTitreArticle(langue: "fr", requete: "\(marquePropre) \(modelePropre)")
        }
        if let titre = titreTrouve {
            if let detail = await recupererResumeDirect(langue: "fr", titre: titre) {
                if detail.photoUrl != nil || detail.resume != nil {
                    cache[cleCache] = detail
                    return detail
                }
            }
        }
        
        // 3. Repli sur Wikipédia en Anglais si aucun résultat probant en français
        if let detailEn = await recupererResumeDirect(langue: "en", titre: requeteDirecte) {
            if detailEn.photoUrl != nil || detailEn.resume != nil {
                cache[cleCache] = detailEn
                return detailEn
            }
        }
        
        if let titreEn = await rechercherTitreArticle(langue: "en", requete: "\(marquePropre) \(modelePropre)") {
            if let detailEn = await recupererResumeDirect(langue: "en", titre: titreEn) {
                cache[cleCache] = detailEn
                return detailEn
            }
        }
        
        return nil
    }
    
    // Requête REST directe sur le endpoint de résumé
    private func recupererResumeDirect(langue: String, titre: String) async -> DetailWikipedia? {
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
            
            let photo = summary.originalimage?.source ?? summary.thumbnail?.source
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
    
    // Recherche par mot-clé pour retrouver la page Wikipédia exacte
    private func rechercherTitreArticle(langue: String, requete: String) async -> String? {
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
            return searchResult.query?.search?.first?.title
        } catch {
            return nil
        }
    }
}
