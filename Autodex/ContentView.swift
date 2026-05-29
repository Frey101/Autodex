//
//  ContentView.swift
//  Autodex
//
//  Created by Alyssia Frey on 29/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        Text("AutoDex")
        .padding(20)
        .font(.largeTitle)
        .foregroundStyle(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
