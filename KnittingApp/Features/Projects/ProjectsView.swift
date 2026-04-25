import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var showingAddProject = false
    @State private var searchText = ""

    var filtered: [Project] {
        guard !searchText.isEmpty else { return projects }
        return projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "Ingen projekter endnu",
                        systemImage: "heart.text.square",
                        description: Text("Tryk + for at tilføje dit første projekt")
                    )
                } else {
                    List {
                        ForEach(filtered) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                ProjectRowView(project: project)
                            }
                        }
                        .onDelete(perform: deleteProjects)
                    }
                    .searchable(text: $searchText, prompt: "Søg i projekter")
                }
            }
            .navigationTitle("Projekter")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddProject = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView()
            }
        }
    }

    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}

struct ProjectRowView: View {
    let project: Project

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.status.icon)
                .foregroundStyle(.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.headline)
                Text(project.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(project.updatedAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
