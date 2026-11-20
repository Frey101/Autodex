//
//  VoitureDuJourWidget.swift
//  AutodexWidget
//
//  Created by Tom Tas on 20/11/2026.
//

import WidgetKit
import SwiftUI

struct VoitureDuJourWidget: Widget {
    let kind: String = "VoitureDuJourWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VoitureDuJourProvider()) { entry in
            VoitureDuJourWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Voiture du Jour")
        .description("Découvrez chaque jour une supercar ou un bolide de légende emblématique.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
