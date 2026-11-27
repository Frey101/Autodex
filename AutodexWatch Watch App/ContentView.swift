import SwiftUI
import WatchKit

/// Type d'énergie utilisé pour filtrer le catalogue sur Apple Watch.
enum WatchEnergie: String, CaseIterable, Identifiable {
    case tous = "Tous"
    case hybride = "Hybride"
    case electrique = "Électrique"
    case essence = "Essence"

    var id: String { rawValue }
}

/// Modèle léger d'un véhicule affiché sur Apple Watch.
struct WatchCar: Identifiable, Hashable {
    let id: String
    let marque: String
    let modele: String
    let puissance: Int
    let carburant: WatchEnergie
    let annee: Int
    let zeroACent: String
    let transmission: String
}

/// Catalogue embarqué optimisé pour consultation rapide au poignet.
private let watchCatalogue: [WatchCar] = [
    WatchCar(id: "f80", marque: "Ferrari", modele: "F80", puissance: 1200, carburant: .hybride, annee: 2025, zeroACent: "2.15 s", transmission: "AWD"),
    WatchCar(id: "tourbillon", marque: "Bugatti", modele: "Tourbillon", puissance: 1800, carburant: .hybride, annee: 2026, zeroACent: "2.0 s", transmission: "AWD"),
    WatchCar(id: "w1", marque: "McLaren", modele: "W1", puissance: 1275, carburant: .hybride, annee: 2025, zeroACent: "2.7 s", transmission: "RWD"),
    WatchCar(id: "gt3rs", marque: "Porsche", modele: "911 GT3 RS", puissance: 525, carburant: .essence, annee: 2024, zeroACent: "3.2 s", transmission: "RWD"),
    WatchCar(id: "macan-ev", marque: "Porsche", modele: "Macan Turbo EV", puissance: 639, carburant: .electrique, annee: 2025, zeroACent: "3.3 s", transmission: "AWD"),
    WatchCar(id: "a290", marque: "Alpine", modele: "A290 GTS", puissance: 220, carburant: .electrique, annee: 2025, zeroACent: "6.4 s", transmission: "FWD"),
    WatchCar(id: "r5", marque: "Renault", modele: "5 E-Tech", puissance: 150, carburant: .electrique, annee: 2025, zeroACent: "8.0 s", transmission: "FWD"),
    WatchCar(id: "revuelto", marque: "Lamborghini", modele: "Revuelto", puissance: 1015, carburant: .hybride, annee: 2024, zeroACent: "2.5 s", transmission: "AWD"),
    WatchCar(id: "i5m60", marque: "BMW", modele: "i5 M60", puissance: 601, carburant: .electrique, annee: 2025, zeroACent: "3.8 s", transmission: "AWD"),
    WatchCar(id: "m4csl", marque: "BMW", modele: "M4 CSL", puissance: 550, carburant: .essence, annee: 2023, zeroACent: "3.7 s", transmission: "RWD"),
    WatchCar(id: "sq6", marque: "Audi", modele: "SQ6 e-tron", puissance: 517, carburant: .electrique, annee: 2025, zeroACent: "4.3 s", transmission: "AWD"),
    WatchCar(id: "r8gt", marque: "Audi", modele: "R8 V10 GT", puissance: 620, carburant: .essence, annee: 2023, zeroACent: "3.4 s", transmission: "RWD"),
    WatchCar(id: "amggt", marque: "Mercedes-AMG", modele: "GT 63 S E", puissance: 816, carburant: .hybride, annee: 2024, zeroACent: "2.8 s", transmission: "AWD"),
    WatchCar(id: "gtr", marque: "Nissan", modele: "GT-R Nismo", puissance: 600, carburant: .essence, annee: 2024, zeroACent: "2.7 s", transmission: "AWD"),
    WatchCar(id: "nsx", marque: "Honda", modele: "NSX Type S", puissance: 602, carburant: .hybride, annee: 2022, zeroACent: "2.9 s", transmission: "AWD")
]

struct WatchContentView: View {
    @AppStorage("watch_favoris_ids") private var favorisRaw: String = "f80,gt3rs"
    @State private var recherche: String = ""
    @State private var filtreEnergie: WatchEnergie = .tous

    private var favorisIDs: Set<String> {
        Set(favorisRaw.split(separator: ",").map(String.init))
    }

    private func toggleFavori(_ id: String) {
        var ids = favorisIDs
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        favorisRaw = ids.sorted().joined(separator: ",")
        WKInterfaceDevice.current().play(.click)
    }

    private var voitureDuJour: WatchCar {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return watchCatalogue[dayIndex % watchCatalogue.count]
    }

    private var bolidesFiltres: [WatchCar] {
        watchCatalogue.filter { car in
            let matchEnergie = (filtreEnergie == .tous || car.carburant == filtreEnergie)
            let matchRecherche = recherche.isEmpty
                || car.marque.localizedCaseInsensitiveContains(recherche)
                || car.modele.localizedCaseInsensitiveContains(recherche)
            return matchEnergie && matchRecherche
        }
    }

    private var favoris: [WatchCar] {
        watchCatalogue.filter { favorisIDs.contains($0.id) }
    }

    var body: some View {
        TabView {
            // 1. Catalogue + Voiture du jour + Recherche
            NavigationStack {
                List {
                    Section("Voiture du jour") {
                        NavigationLink(destination: WatchCarDetailView(car: voitureDuJour, estFavori: favorisIDs.contains(voitureDuJour.id), onToggleFavori: { toggleFavori(voitureDuJour.id) })) {
                            WatchCarRow(car: voitureDuJour, estFavori: favorisIDs.contains(voitureDuJour.id))
                        }
                    }

                    Section("Filtre") {
                        Picker("Énergie", selection: $filtreEnergie) {
                            ForEach(WatchEnergie.allCases) { energie in
                                Text(energie.rawValue).tag(energie)
                            }
                        }
                    }

                    Section("Catalogue (\(bolidesFiltres.count))") {
                        ForEach(bolidesFiltres) { car in
                            NavigationLink(destination: WatchCarDetailView(car: car, estFavori: favorisIDs.contains(car.id), onToggleFavori: { toggleFavori(car.id) })) {
                                WatchCarRow(car: car, estFavori: favorisIDs.contains(car.id))
                            }
                        }
                    }
                }
                .searchable(text: $recherche, prompt: "Marque ou modèle")
                .navigationTitle("AutoDex")
            }

            // 2. Favoris
            NavigationStack {
                Group {
                    if favoris.isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "heart.slash")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Text("Aucun favori")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        List(favoris) { car in
                            NavigationLink(destination: WatchCarDetailView(car: car, estFavori: true, onToggleFavori: { toggleFavori(car.id) })) {
                                WatchCarRow(car: car, estFavori: true)
                            }
                        }
                    }
                }
                .navigationTitle("Favoris (\(favoris.count))")
            }

            // 3. Mini-Duel au poignet
            WatchMiniDuelView(bolides: watchCatalogue)
        }
        .tabViewStyle(.verticalPage)
    }
}

struct WatchCarRow: View {
    let car: WatchCar
    let estFavori: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(car.marque)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(car.modele)
                    .font(.headline)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(car.puissance) ch")
                    .font(.caption2.bold())
                    .foregroundStyle(.red)
                if estFavori {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.pink)
                }
            }
        }
    }
}

struct WatchCarDetailView: View {
    let car: WatchCar
    let estFavori: Bool
    let onToggleFavori: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(car.marque)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(car.modele)
                            .font(.headline)
                    }
                    Spacer()
                    Button(action: onToggleFavori) {
                        Image(systemName: estFavori ? "heart.fill" : "heart")
                            .foregroundStyle(estFavori ? .pink : .secondary)
                    }
                    .buttonStyle(.plain)
                }

                Divider()

                Label("\(car.puissance) ch", systemImage: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Label("0-100 : \(car.zeroACent)", systemImage: "gauge.with.needle.fill")
                    .font(.caption)
                Label(car.carburant.rawValue, systemImage: "fuelpump.fill")
                    .font(.caption)
                Label("\(car.transmission) • \(car.annee)", systemImage: "car.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
        .navigationTitle(car.marque)
    }
}

struct WatchMiniDuelView: View {
    let bolides: [WatchCar]
    @State private var indexA = 0
    @State private var indexB = 1
    @State private var duelsJoues = 0

    var body: some View {
        let carA = bolides[indexA]
        let carB = bolides[indexB]
        let gagnant = carA.puissance >= carB.puissance ? carA : carB
        let ecart = abs(carA.puissance - carB.puissance)

        VStack(spacing: 5) {
            Text("Mini-Duel • #\(duelsJoues + 1)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text("\(carA.marque) \(carA.modele)")
                .font(.caption.bold())
                .lineLimit(1)
                .foregroundStyle(gagnant.id == carA.id ? .green : .primary)
            Text("\(carA.puissance) ch")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text("VS (+\(ecart) ch)")
                .font(.caption2.bold())
                .foregroundStyle(.red)

            Text("\(carB.marque) \(carB.modele)")
                .font(.caption.bold())
                .lineLimit(1)
                .foregroundStyle(gagnant.id == carB.id ? .green : .primary)
            Text("\(carB.puissance) ch")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button("Nouveau duel") {
                indexA = Int.random(in: 0..<bolides.count)
                indexB = (indexA + Int.random(in: 1..<bolides.count)) % bolides.count
                duelsJoues += 1
                WKInterfaceDevice.current().play(.success)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(.horizontal, 4)
    }
}
