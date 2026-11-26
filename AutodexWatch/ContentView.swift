import SwiftUI

struct WatchCar: Identifiable {
    let id: String
    let marque: String
    let modele: String
    let puissance: Int
    let carburant: String
    let annee: Int
}

struct WatchContentView: View {
    private let bolides: [WatchCar] = [
        WatchCar(id: "1", marque: "Ferrari", modele: "F80", puissance: 1200, carburant: "Hybride", annee: 2025),
        WatchCar(id: "2", marque: "Bugatti", modele: "Tourbillon", puissance: 1800, carburant: "Hybride", annee: 2026),
        WatchCar(id: "3", marque: "Porsche", modele: "911 GT3 RS", puissance: 525, carburant: "Essence", annee: 2024),
        WatchCar(id: "4", marque: "McLaren", modele: "W1", puissance: 1275, carburant: "Hybride", annee: 2025),
        WatchCar(id: "5", marque: "Alpine", modele: "A290", puissance: 220, carburant: "Électrique", annee: 2025)
    ]

    var body: some View {
        TabView {
            NavigationStack {
                List(bolides) { car in
                    NavigationLink(destination: WatchCarDetailView(car: car)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(car.marque)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(car.modele)
                                    .font(.headline)
                            }
                            Spacer()
                            Text("\(car.puissance) ch")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .navigationTitle("AutoDex")
            }

            WatchMiniDuelView(bolides: bolides)
        }
        .tabViewStyle(.verticalPage)
    }
}

struct WatchCarDetailView: View {
    let car: WatchCar

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(car.marque) \(car.modele)")
                    .font(.headline)
                Label("\(car.puissance) ch", systemImage: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Label(car.carburant, systemImage: "fuelpump.fill")
                    .font(.caption)
                Label("Année \(car.annee)", systemImage: "calendar")
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

    var body: some View {
        let carA = bolides[indexA]
        let carB = bolides[indexB]
        let gagnant = carA.puissance >= carB.puissance ? carA : carB

        VStack(spacing: 6) {
            Text("Mini-Duel")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(carA.modele) (\(carA.puissance) ch)")
                .font(.caption)
                .foregroundStyle(gagnant.id == carA.id ? .green : .primary)
            Text("VS")
                .font(.caption2)
                .foregroundStyle(.red)
            Text("\(carB.modele) (\(carB.puissance) ch)")
                .font(.caption)
                .foregroundStyle(gagnant.id == carB.id ? .green : .primary)
            Button("Nouveau duel") {
                indexA = Int.random(in: 0..<bolides.count)
                indexB = (indexA + Int.random(in: 1..<bolides.count)) % bolides.count
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }
}
