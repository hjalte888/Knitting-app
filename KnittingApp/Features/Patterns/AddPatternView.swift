import SwiftUI
import SwiftData

struct AddPatternView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var gaugeStitches = 22.0
    @State private var gaugeRows = 30.0
    @State private var gaugeUnit: GaugeUnit = .per10cm
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Opskrift") {
                    TextField("Titel", text: $title)
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                }
                Section("Strikkefasthed (gauge)") {
                    Picker("Enhed", selection: $gaugeUnit) {
                        ForEach(GaugeUnit.allCases, id: \.self) { u in
                            Text(u.rawValue).tag(u)
                        }
                    }
                    .pickerStyle(.segmented)
                    HStack {
                        Text("Masker")
                        Spacer()
                        TextField("", value: $gaugeStitches, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text(gaugeUnit.rawValue)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    HStack {
                        Text("Rækker")
                        Spacer()
                        TextField("", value: $gaugeRows, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text(gaugeUnit.rawValue)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                Section("Noter") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Ny opskrift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuller") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tilføj") {
                        let pattern = Pattern(
                            title: title,
                            content: content,
                            patternGaugeStitches: gaugeStitches,
                            patternGaugeRows: gaugeRows,
                            gaugeUnit: gaugeUnit,
                            notes: notes
                        )
                        modelContext.insert(pattern)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
