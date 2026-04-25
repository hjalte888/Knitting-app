import SwiftUI

struct TimerView: View {
    @State private var isRunning = false
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    @State private var sessions: [TimeInterval] = []

    var body: some View {
        VStack(spacing: 32) {
            Text(formatTime(elapsed))
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .foregroundStyle(isRunning ? .primary : .secondary)
                .animation(.easeInOut, value: isRunning)

            HStack(spacing: 24) {
                Button(action: reset) {
                    Text("Nulstil")
                        .frame(width: 100)
                }
                .buttonStyle(.bordered)
                .disabled(elapsed == 0)

                Button(action: toggleTimer) {
                    Text(isRunning ? "Pause" : "Start")
                        .frame(width: 100)
                }
                .buttonStyle(.borderedProminent)

                Button(action: lap) {
                    Text("Omgang")
                        .frame(width: 100)
                }
                .buttonStyle(.bordered)
                .disabled(!isRunning && elapsed == 0)
            }

            if !sessions.isEmpty {
                List {
                    ForEach(sessions.indices, id: \.self) { i in
                        HStack {
                            Text("Session \(i + 1)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(formatTime(sessions[i]))
                                .font(.body.monospacedDigit())
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .padding()
        .navigationTitle("Timer")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { stopTimer() }
    }

    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsed += 0.1
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func reset() {
        stopTimer()
        elapsed = 0
    }

    private func lap() {
        sessions.append(elapsed)
        elapsed = 0
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        let s = Int(interval) % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }
}
