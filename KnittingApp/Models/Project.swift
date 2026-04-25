import SwiftData
import Foundation

@Model
final class Project {
    var name: String
    var status: ProjectStatus
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var photoData: Data?

    @Relationship(deleteRule: .nullify) var pattern: Pattern?
    @Relationship(deleteRule: .nullify) var yarn: YarnStash?

    init(name: String, status: ProjectStatus = .planning, notes: String = "") {
        self.name = name
        self.status = status
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ProjectStatus: String, Codable, CaseIterable {
    case planning = "Planlægning"
    case active = "Aktiv"
    case finished = "Færdig"
    case frogged = "Frog'et"

    var icon: String {
        switch self {
        case .planning: return "list.clipboard"
        case .active: return "heart"
        case .finished: return "checkmark.circle"
        case .frogged: return "arrow.counterclockwise"
        }
    }
}
