import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ProjectsView()
                .tabItem { Label("Projekter", systemImage: "heart.text.square") }

            PatternsView()
                .tabItem { Label("Opskrifter", systemImage: "book") }

            ToolsView()
                .tabItem { Label("Værktøjer", systemImage: "dial.medium") }

            YarnStashView()
                .tabItem { Label("Garnlager", systemImage: "shippingbox") }

            YarnFinderView()
                .tabItem { Label("Søg Garn", systemImage: "magnifyingglass") }
        }
    }
}
