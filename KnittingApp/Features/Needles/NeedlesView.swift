import SwiftUI
import SwiftData

struct NeedlesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Needle.sizeMm) private var needles: [Needle]
    @State private var showingAddNeedle = false
    @State private var filterType: NeedleType?

    var filtered: [Needle] {
        filterType == nil ? needles : needles.filter { $0.type == filterType }
    }

    var body: some View {
        Group {
            if needles.isEmpty {
                ContentUnavailableView(
                    "Ingen nåle registreret",
                    systemImage: "pencil.tip",
                    description: Text("Tryk + for at tilføje pinde eller nåle")
                )
            } else {
                List {
                    Picker("Type", selection: $filterType) {
                        Text("Alle").tag(Optional<NeedleType>.none)
                        ForEach(NeedleType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(Optional(t))
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)

                    ForEach(filtered) { needle in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(needle.displaySize)
                                    .font(.headline)
                                Text("\(needle.type.rawValue) · \(needle.material.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !needle.brand.isEmpty {
                                Text(needle.brand)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .onDelete(perform: deleteNeedles)
                }
            }
        }
        .navigationTitle("Nåleinventar")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddNeedle = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddNeedle) {
            AddNeedleView()
        }
    }

    private func deleteNeedles(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}

struct AddNeedleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var sizeMm = 4.0
    @State private var type: NeedleType = .straight
    @State private var material: NeedleMaterial = .bamboo
    @State private var brand = ""
    @State private var notes = ""

    private let commonSizes: [Double] = [2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 8.0, 9.0, 10.0, 12.0, 15.0]

    var body: some View {
        NavigationStack {
            Form {
                Section("Størrelse") {
                    Picker("Størrelse (mm)", selection: $sizeMm) {
                        ForEach(commonSizes, id: \.self) { size in
                            Text("\(size, specifier: size.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f") mm").tag(size)
                        }
                    }
                }
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(NeedleType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    Picker("Materiale", selection: $material) {
                        ForEach(NeedleMaterial.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                }
                Section("Mærke") {
                    TextField("Mærke (valgfrit)", text: $brand)
                }
            }
            .navigationTitle("Tilføj nål")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuller") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tilføj") {
                        modelContext.insert(Needle(sizeMm: sizeMm, type: type, material: material, brand: brand, notes: notes))
                        dismiss()
                    }
                }
            }
        }
    }
}
