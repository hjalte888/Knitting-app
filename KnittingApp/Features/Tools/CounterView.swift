import SwiftUI

struct CounterView: View {
    @State private var rowCount = 0
    @State private var stitchCount = 0

    var body: some View {
        VStack(spacing: 40) {
            counterSection(title: "Rækker", count: $rowCount, color: .blue)
            Divider()
            counterSection(title: "Masker", count: $stitchCount, color: .purple)
        }
        .padding(32)
        .navigationTitle("Tæller")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func counterSection(title: String, count: Binding<Int>, color: Color) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("\(count.wrappedValue)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.2), value: count.wrappedValue)

            HStack(spacing: 24) {
                Button(action: {
                    if count.wrappedValue > 0 {
                        count.wrappedValue -= 1
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(color.opacity(0.6))
                }

                Button(action: {
                    count.wrappedValue += 1
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(color)
                }

                Button(action: {
                    count.wrappedValue = 0
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
