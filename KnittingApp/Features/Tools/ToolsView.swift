import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: CounterView()) {
                    Label("Tæller", systemImage: "dial.medium")
                }
                NavigationLink(destination: TimerView()) {
                    Label("Timer", systemImage: "timer")
                }
                NavigationLink(destination: NeedlesView()) {
                    Label("Nåleinventar", systemImage: "pencil.tip")
                }
                NavigationLink(destination: GaugeAdjusterView()) {
                    Label("Gauge-justér opskrift", systemImage: "slider.horizontal.3")
                }
            }
            .navigationTitle("Værktøjer")
        }
    }
}
