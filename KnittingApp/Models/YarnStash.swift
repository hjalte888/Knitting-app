import SwiftData
import Foundation

@Model
final class YarnStash {
    var name: String
    var brand: String
    var colorName: String
    var colorCode: String
    var weightCategory: YarnWeight
    var fiberContent: String
    var metersPerSkein: Int
    var gramsPerSkein: Int
    var skeinCount: Double
    var notes: String
    var imageData: Data?
    var createdAt: Date

    init(
        name: String,
        brand: String = "",
        colorName: String = "",
        colorCode: String = "",
        weightCategory: YarnWeight = .dk,
        fiberContent: String = "",
        metersPerSkein: Int = 0,
        gramsPerSkein: Int = 100,
        skeinCount: Double = 1,
        notes: String = ""
    ) {
        self.name = name
        self.brand = brand
        self.colorName = colorName
        self.colorCode = colorCode
        self.weightCategory = weightCategory
        self.fiberContent = fiberContent
        self.metersPerSkein = metersPerSkein
        self.gramsPerSkein = gramsPerSkein
        self.skeinCount = skeinCount
        self.notes = notes
        self.createdAt = Date()
    }

    var totalMeters: Double {
        Double(metersPerSkein) * skeinCount
    }
}

enum YarnWeight: String, Codable, CaseIterable {
    case lace = "Lace"
    case fingering = "Fingering / Sokke"
    case sport = "Sport"
    case dk = "DK"
    case worsted = "Worsted"
    case aran = "Aran"
    case bulky = "Bulky"
    case superBulky = "Super Bulky"

    var gaugeRange: ClosedRange<Double> {
        switch self {
        case .lace:       return 32...40
        case .fingering:  return 27...32
        case .sport:      return 23...26
        case .dk:         return 21...24
        case .worsted:    return 16...20
        case .aran:       return 14...16
        case .bulky:      return 9...13
        case .superBulky: return 1...8
        }
    }

    var needleSize: String {
        switch self {
        case .lace:       return "1.5–2.25 mm"
        case .fingering:  return "2.25–3.25 mm"
        case .sport:      return "3.25–3.75 mm"
        case .dk:         return "3.75–4.5 mm"
        case .worsted:    return "4.5–5.5 mm"
        case .aran:       return "5.5–6.5 mm"
        case .bulky:      return "6.5–9 mm"
        case .superBulky: return "9+ mm"
        }
    }
}
