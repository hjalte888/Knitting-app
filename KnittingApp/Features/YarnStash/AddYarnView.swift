import SwiftUI
import SwiftData

struct AddYarnView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var brand = ""
    @State private var colorName = ""
    @State private var colorCode = ""
    @State private var weightCategory: YarnWeight = .dk
    @State private var fiberContent = ""
    @State private var metersPerSkein = 200
    @State private var gramsPerSkein = 100
    @State private var skeinCount = 1.0
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Garn") {
                    TextField("Mærke (fx Drops, Sandnes)", text: $brand)
                    TextField("Navn (fx Karisma, Alpakka)", text: $name)
                    Picker("Vægt", selection: $weightCategory) {
                        ForEach(YarnWeight.allCases, id: \.self) { w in
                            VStack(alignment: .leading) {
                                Text(w.rawValue)
                                Text(w.needleSize).font(.caption).foregroundStyle(.secondary)
                            }
                            .tag(w)
                        }
                    }
                }
                Section("Farve") {
                    TextField("Farvenavn (fx Støvet blå)", text: $colorName)
                    TextField("Farvenummer (fx 6347)", text: $colorCode)
                        .keyboardType(.numberPad)
                }
                Section("Mængde") {
                    HStack {
                        Text("Meter per nøgle")
                        Spacer()
                        TextField("", value: $metersPerSkein, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Gram per nøgle")
                        Spacer()
                        TextField("", value: $gramsPerSkein, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Antal nøgler")
                        Spacer()
                        Stepper("\(skeinCount, specifier: "%.0f")", value: $skeinCount, in: 0.5...100, step: 0.5)
                    }
                }
                Section("Fiber") {
                    TextField("Fiberindhold (fx 100% merino)", text: $fiberContent)
                }
                Section("Noter") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Tilføj garn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuller") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tilføj") {
                        let yarn = YarnStash(
                            name: name, brand: brand, colorName: colorName,
                            colorCode: colorCode, weightCategory: weightCategory,
                            fiberContent: fiberContent, metersPerSkein: metersPerSkein,
                            gramsPerSkein: gramsPerSkein, skeinCount: skeinCount, notes: notes
                        )
                        modelContext.insert(yarn)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty && brand.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct YarnDetailView: View {
    @Bindable var yarn: YarnStash

    var body: some View {
        Form {
            Section("Info") {
                LabeledContent("Mærke", value: yarn.brand)
                LabeledContent("Navn", value: yarn.name)
                LabeledContent("Vægt", value: yarn.weightCategory.rawValue)
                LabeledContent("Nålestørrelse", value: yarn.weightCategory.needleSize)
                if !yarn.fiberContent.isEmpty {
                    LabeledContent("Fiber", value: yarn.fiberContent)
                }
            }
            Section("Farve") {
                LabeledContent("Farvenavn", value: yarn.colorName)
                LabeledContent("Farvenummer", value: yarn.colorCode)
            }
            Section("Lager") {
                LabeledContent("Nøgler", value: "\(yarn.skeinCount, specifier: "%.1f")")
                LabeledContent("Total", value: "\(Int(yarn.totalMeters)) m · \(Int(yarn.skeinCount * Double(yarn.gramsPerSkein))) g")
            }
            if !yarn.notes.isEmpty {
                Section("Noter") {
                    Text(yarn.notes)
                }
            }
        }
        .navigationTitle("\(yarn.brand) \(yarn.name)")
    }
}
