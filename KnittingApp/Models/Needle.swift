import SwiftData
import Foundation

@Model
final class Needle {
    var sizeMm: Double
    var type: NeedleType
    var material: NeedleMaterial
    var brand: String
    var notes: String
    var createdAt: Date

    init(
        sizeMm: Double,
        type: NeedleType = .straight,
        material: NeedleMaterial = .bamboo,
        brand: String = "",
        notes: String = ""
    ) {
        self.sizeMm = sizeMm
        self.type = type
        self.material = material
        self.brand = brand
        self.notes = notes
        self.createdAt = Date()
    }

    var displaySize: String {
        sizeMm.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(sizeMm)) mm"
            : "\(sizeMm) mm"
    }
}

enum NeedleType: String, Codable, CaseIterable {
    case straight = "Strikkepinde"
    case circular = "Rundpinde"
    case dpn = "Strømpepinde"
    case crochet = "Hæklenål"
}

enum NeedleMaterial: String, Codable, CaseIterable {
    case bamboo = "Bambus"
    case wood = "Træ"
    case metal = "Metal"
    case plastic = "Plast"
}
