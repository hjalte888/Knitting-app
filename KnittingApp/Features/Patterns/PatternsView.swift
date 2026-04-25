import SwiftUI
import SwiftData

struct PatternsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pattern.createdAt, order: .reverse) private var patterns: [Pattern]
    @State private var showingAddPattern = false
    @State private var searchText = ""

    var filtered: [Pattern] {
        guard !searchText.isEmpty else { return patterns }
        return patterns.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if patterns.isEmpty {
                    ContentUnavailableView(
                        "Ingen opskrifter endnu",
                        systemImage: "book",
                        description: Text("Tryk + for at tilføje en opskrift")
                    )
                } else {
                    List {
                        ForEach(filtered) { pattern in
                            NavigationLink(destination: PatternDetailView(pattern: pattern)) {
                                PatternRowView(pattern: pattern)
                            }
                        }
                        .onDelete(perform: deletePatterns)
                    }
                    .searchable(text: $searchText, prompt: "Søg i opskrifter")
                }
            }
            .navigationTitle("Opskrifter")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPattern = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddPattern) {
                AddPatternView()
            }
        }
    }

    private func deletePatterns(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}

struct PatternRowView: View {
    let pattern: Pattern

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(pattern.title)
                .font(.headline)
            Text("\(pattern.patternGaugeStitches, specifier: "%.0f") m / \(pattern.patternGaugeRows, specifier: "%.0f") r \(pattern.gaugeUnit.rawValue)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
