import SwiftUI
import SwiftData

struct YarnStashView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \YarnStash.brand) private var yarns: [YarnStash]
    @State private var showingAddYarn = false
    @State private var searchText = ""
    @State private var filterWeight: YarnWeight?

    var filtered: [YarnStash] {
        yarns.filter { yarn in
            let matchesSearch = searchText.isEmpty ||
                yarn.name.localizedCaseInsensitiveContains(searchText) ||
                yarn.brand.localizedCaseInsensitiveContains(searchText)
            let matchesWeight = filterWeight == nil || yarn.weightCategory == filterWeight
            return matchesSearch && matchesWeight
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if yarns.isEmpty {
                    ContentUnavailableView(
                        "Garnlageret er tomt",
                        systemImage: "shippingbox",
                        description: Text("Tryk + for at registrere dit garn")
                    )
                } else {
                    List {
                        weightFilterPicker
                        ForEach(filtered) { yarn in
                            NavigationLink(destination: YarnDetailView(yarn: yarn)) {
                                YarnRowView(yarn: yarn)
                            }
                        }
                        .onDelete(perform: deleteYarns)
                    }
                    .searchable(text: $searchText, prompt: "Søg i garn")
                }
            }
            .navigationTitle("Garnlager")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddYarn = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddYarn) {
                AddYarnView()
            }
        }
    }

    @ViewBuilder
    private var weightFilterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                FilterChip(label: "Alle", isSelected: filterWeight == nil) {
                    filterWeight = nil
                }
                ForEach(YarnWeight.allCases, id: \.self) { weight in
                    FilterChip(label: weight.rawValue, isSelected: filterWeight == weight) {
                        filterWeight = filterWeight == weight ? nil : weight
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .listRowBackground(Color.clear)
    }

    private func deleteYarns(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.secondarySystemBackground)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct YarnRowView: View {
    let yarn: YarnStash

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("\(yarn.brand) \(yarn.name)")
                    .font(.headline)
                Spacer()
                Text(yarn.weightCategory.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.secondarySystemBackground)
                    .clipShape(Capsule())
            }
            HStack {
                Text(yarn.colorName.isEmpty ? yarn.colorCode : "\(yarn.colorName) (\(yarn.colorCode))")
                Spacer()
                Text("\(yarn.skeinCount, specifier: "%.0f") ngl · \(Int(yarn.totalMeters)) m")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
