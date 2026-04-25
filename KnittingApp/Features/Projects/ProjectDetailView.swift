import SwiftUI
import SwiftData
import PhotosUI

struct ProjectDetailView: View {
    @Bindable var project: Project
    @State private var photoItem: PhotosPickerItem?
    @State private var isEditingNotes = false

    var body: some View {
        Form {
            Section("Status") {
                Picker("Status", selection: $project.status) {
                    ForEach(ProjectStatus.allCases, id: \.self) { s in
                        Label(s.rawValue, systemImage: s.icon).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: project.status) { project.updatedAt = Date() }
            }

            Section("Foto") {
                if let data = project.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label(project.photoData == nil ? "Tilføj foto" : "Skift foto", systemImage: "photo")
                }
                .onChange(of: photoItem) { loadPhoto() }
            }

            Section("Tilknyttet") {
                if let pattern = project.pattern {
                    LabeledContent("Opskrift", value: pattern.title)
                } else {
                    Text("Ingen opskrift tilknyttet").foregroundStyle(.secondary)
                }
                if let yarn = project.yarn {
                    LabeledContent("Garn", value: "\(yarn.brand) \(yarn.name)")
                } else {
                    Text("Intet garn tilknyttet").foregroundStyle(.secondary)
                }
            }

            Section("Noter") {
                TextEditor(text: $project.notes)
                    .frame(minHeight: 120)
                    .onChange(of: project.notes) { project.updatedAt = Date() }
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private func loadPhoto() {
        Task {
            if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                project.photoData = data
                project.updatedAt = Date()
            }
        }
    }
}
