import SwiftUI
import SwiftData

struct AddProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var status: ProjectStatus = .planning
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Projekt") {
                    TextField("Navn (fx 'Blå sweater')", text: $name)
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                }
                Section("Noter") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Nyt projekt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuller") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tilføj") {
                        let project = Project(name: name, status: status, notes: notes)
                        modelContext.insert(project)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
