import SwiftUI

struct PatternDetailView: View {
    @Bindable var pattern: Pattern
    @State private var showingGaugeAdjuster = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strikkefasthed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(pattern.patternGaugeStitches, specifier: "%.0f") masker / \(pattern.patternGaugeRows, specifier: "%.0f") rækker \(pattern.gaugeUnit.rawValue)")
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button(action: { showingGaugeAdjuster = true }) {
                    Label("Justér til min strikkefasthed", systemImage: "slider.horizontal.3")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if !pattern.content.isEmpty {
                    Text("Opskrift")
                        .font(.headline)
                    Text(pattern.content)
                        .font(.body)
                }

                if !pattern.notes.isEmpty {
                    Text("Noter")
                        .font(.headline)
                    Text(pattern.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(pattern.title)
        .sheet(isPresented: $showingGaugeAdjuster) {
            GaugeAdjusterView(pattern: pattern)
        }
    }
}
