import SwiftUI

struct YarnFinderView: View {
    @State private var searchText = ""
    @State private var selectedYarn: YarnEntry?
    @State private var alternatives: [ScoredYarn] = []
    @State private var manualGauge = ""
    @State private var useManualGauge = false

    private let db = YarnDatabase.shared

    var searchResults: [YarnEntry] {
        db.search(searchText)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Søg på fasthed (masker/10cm)", isOn: $useManualGauge)
                    if useManualGauge {
                        HStack {
                            TextField("Masker per 10 cm", text: $manualGauge)
                                .keyboardType(.decimalPad)
                            Button("Find") { searchByGauge() }
                                .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Søgemåde")
                }

                if !useManualGauge {
                    if searchText.isEmpty {
                        Section {
                            Text("Skriv et garnnavn for at søge, fx \"Drops Karisma\"")
                                .foregroundStyle(.secondary)
                                .font(.callout)
                        }
                    } else if selectedYarn == nil {
                        Section("Søgeresultater") {
                            ForEach(searchResults) { yarn in
                                Button(action: { selectYarn(yarn) }) {
                                    YarnEntryRow(yarn: yarn)
                                }
                                .tint(.primary)
                            }
                            if searchResults.isEmpty {
                                Text("Ingen resultater")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if let selected = selectedYarn {
                    Section {
                        YarnEntryRow(yarn: selected)
                        Button("Ryd valg") {
                            selectedYarn = nil
                            alternatives = []
                            searchText = ""
                        }
                        .foregroundStyle(.red)
                    } header: {
                        Text("Valgt garn")
                    }
                }

                if !alternatives.isEmpty {
                    Section {
                        ForEach(alternatives.prefix(20)) { scored in
                            AlternativeYarnRow(scored: scored)
                        }
                    } header: {
                        Text("Alternativer (\(min(alternatives.count, 20)) af \(alternatives.count))")
                    }
                }
            }
            .navigationTitle("Søg alternativt garn")
            .searchable(text: $searchText, prompt: "Fx Drops Karisma")
            .onChange(of: searchText) {
                if !useManualGauge {
                    selectedYarn = nil
                    alternatives = []
                }
            }
        }
    }

    private func selectYarn(_ yarn: YarnEntry) {
        selectedYarn = yarn
        searchText = "\(yarn.brand) \(yarn.name)"
        alternatives = db.findAlternatives(for: yarn)
    }

    private func searchByGauge() {
        guard let gauge = Double(manualGauge.replacingOccurrences(of: ",", with: ".")) else { return }
        alternatives = db.findAlternativesForGauge(stitchesPer10cm: gauge)
        selectedYarn = nil
    }
}

struct YarnEntryRow: View {
    let yarn: YarnEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(yarn.brand) – \(yarn.name)")
                    .font(.headline)
                Spacer()
                Text(yarn.weightCategory)
                    .font(.caption)
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(.secondarySystemBackground)
                    .clipShape(Capsule())
            }
            HStack {
                Text("\(yarn.gaugeMin, specifier: "%.0f")–\(yarn.gaugeMax, specifier: "%.0f") m/10cm · \(yarn.needleSize)")
                Spacer()
                Text(yarn.fiber)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct AlternativeYarnRow: View {
    let scored: ScoredYarn

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: matchIcon(scored.gaugeDiff))
                    .foregroundStyle(matchColor(scored.gaugeDiff))
                Text("\(scored.yarn.brand) – \(scored.yarn.name)")
                    .font(.headline)
            }
            HStack {
                Text(scored.matchDescription)
                    .font(.caption)
                    .foregroundStyle(matchColor(scored.gaugeDiff))
                Text("·")
                Text("\(scored.yarn.gaugeMin, specifier: "%.0f")–\(scored.yarn.gaugeMax, specifier: "%.0f") m/10cm · \(scored.yarn.needleSize)")
                Spacer()
                Text(scored.yarn.weightCategory)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if !scored.yarn.fiber.isEmpty {
                Text(scored.yarn.fiber)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }

    private func matchIcon(_ diff: Double) -> String {
        if diff < 0.5 { return "checkmark.seal.fill" }
        if diff < 1.5 { return "checkmark.circle.fill" }
        return "circle.fill"
    }

    private func matchColor(_ diff: Double) -> Color {
        if diff < 0.5 { return .green }
        if diff < 1.5 { return .orange }
        return .secondary
    }
}
