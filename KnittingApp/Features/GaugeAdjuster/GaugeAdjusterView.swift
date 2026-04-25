import SwiftUI

struct GaugeAdjusterView: View {
    let pattern: Pattern?

    @State private var patternStitches: Double
    @State private var patternRows: Double
    @State private var myStitches: Double = 22
    @State private var myRows: Double = 30
    @State private var inputText: String
    @State private var result: AdjustedPattern?
    @State private var showResult = false
    @Environment(\.dismiss) private var dismiss

    init(pattern: Pattern? = nil) {
        self.pattern = pattern
        _patternStitches = State(initialValue: pattern?.patternGaugeStitches ?? 22)
        _patternRows = State(initialValue: pattern?.patternGaugeRows ?? 30)
        _inputText = State(initialValue: pattern?.content ?? "")
    }

    private var stitchFactor: Double { myStitches / patternStitches }
    private var rowFactor: Double { myRows / patternRows }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    gaugeRow(label: "Opskriftens masker", value: $patternStitches)
                    gaugeRow(label: "Opskriftens rækker", value: $patternRows)
                } header: {
                    Text("Opskriftens strikkefasthed")
                } footer: {
                    Text("Masker og rækker per 10 cm")
                }

                Section {
                    gaugeRow(label: "Mine masker", value: $myStitches)
                    gaugeRow(label: "Mine rækker", value: $myRows)
                } header: {
                    Text("Din strikkefasthed")
                } footer: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Strik en prøvelap på 15×15 cm og mål")
                    }
                }

                Section("Faktorer") {
                    LabeledContent("Maskefaktor") {
                        Text(stitchFactor, format: .number.precision(.fractionLength(3)))
                            .foregroundStyle(factorColor(stitchFactor))
                    }
                    LabeledContent("Rækkefaktor") {
                        Text(rowFactor, format: .number.precision(.fractionLength(3)))
                            .foregroundStyle(factorColor(rowFactor))
                    }
                }

                Section("Opskriftstekst") {
                    TextEditor(text: $inputText)
                        .frame(minHeight: 120)
                        .font(.body)
                }

                Button(action: adjust) {
                    Label("Justér opskrift", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Gauge-justering")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Luk") { dismiss() }
                }
            }
            .sheet(isPresented: $showResult) {
                if let result {
                    AdjustedPatternView(result: result)
                }
            }
        }
    }

    @ViewBuilder
    private func gaugeRow(label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
        }
    }

    private func factorColor(_ factor: Double) -> Color {
        if abs(factor - 1.0) < 0.05 { return .green }
        if abs(factor - 1.0) < 0.15 { return .orange }
        return .red
    }

    private func adjust() {
        result = GaugeParser.adjust(
            text: inputText,
            stitchFactor: stitchFactor,
            rowFactor: rowFactor
        )
        showResult = true
    }
}

struct AdjustedPatternView: View {
    let result: AdjustedPattern
    @State private var showChanges = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if !result.changes.isEmpty {
                        Button(action: { showChanges.toggle() }) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle")
                                Text("\(result.changes.count) ændringer foretaget")
                                Spacer()
                                Image(systemName: showChanges ? "chevron.up" : "chevron.down")
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.accent)

                        if showChanges {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(result.changes.indices, id: \.self) { i in
                                    let change = result.changes[i]
                                    HStack {
                                        Image(systemName: changeIcon(change.type))
                                            .foregroundStyle(.secondary)
                                            .frame(width: 20)
                                        Text(change.original)
                                            .strikethrough()
                                            .foregroundStyle(.secondary)
                                        Image(systemName: "arrow.right")
                                            .font(.caption)
                                        Text(change.adjusted)
                                            .bold()
                                            .foregroundStyle(.accent)
                                    }
                                    .font(.caption)
                                }
                            }
                            .padding()
                            .background(.secondarySystemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Text("Justeret opskrift")
                        .font(.headline)

                    Text(result.adjustedText)
                        .font(.body)
                        .textSelection(.enabled)
                }
                .padding()
            }
            .navigationTitle("Justeret opskrift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Luk") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: result.adjustedText)
                }
            }
        }
    }

    private func changeIcon(_ type: GaugeMatch.MatchType) -> String {
        switch type {
        case .stitches: return "square.grid.3x3"
        case .rows: return "line.3.horizontal"
        case .measurement: return "ruler"
        }
    }
}
