//
//  VoitureDuJourProvider.swift
//  AutodexWidget
//
//  Created by Tom Tas on 20/11/2026.
//

import WidgetKit
import SwiftUI

struct VoitureDuJourProvider: TimelineProvider {
    
    // MARK: - Placeholder lors de la configuration
    func placeholder(in context: Context) -> VoitureDuJourEntry {
        let voitureParDefaut = WidgetDataManager.catalogueEmblematique[0] // Porsche 911 GT3 RS
        return VoitureDuJourEntry(date: Date(), voiture: voitureParDefaut, estPlaceholder: true)
    }
    
    // MARK: - Snapshot pour la galerie de widgets iOS
    func getSnapshot(in context: Context, completion: @escaping (VoitureDuJourEntry) -> Void) {
        let voiture = WidgetDataManager.obtenirVoitureDuJour(pour: Date())
        let entry = VoitureDuJourEntry(date: Date(), voiture: voiture)
        completion(entry)
    }
    
    // MARK: - Timeline Quotidienne
    func getTimeline(in context: Context, completion: @escaping (Timeline<VoitureDuJourEntry>) -> Void) {
        let maintenant = Date()
        let voitureAujourdhui = WidgetDataManager.obtenirVoitureDuJour(pour: maintenant)
        let entreeActuelle = VoitureDuJourEntry(date: maintenant, voiture: voitureAujourdhui)
        
        // Prochaine bascule automatique à minuit (lendemain 00:00:00)
        let prochainMinuit = WidgetDataManager.prochaineDateRafraichissement(depuis: maintenant)
        
        let timeline = Timeline(entries: [entreeActuelle], policy: .after(prochainMinuit))
        completion(timeline)
    }
}
