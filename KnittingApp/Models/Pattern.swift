import SwiftData
import Foundation

@Model
final class Pattern {
    var title: String
    var content: String
    var patternGaugeStitches: Double
    var patternGaugeRows: Double
    var gaugeUnit: GaugeUnit
    var notes: String
    var createdAt: Date
    var imageData: Data?

    init(
        title: String,
        content: String = "",
        patternGaugeStitches: Double = 22,
        patternGaugeRows: Double = 30,
        gaugeUnit: GaugeUnit = .per10cm,
        notes: String = ""
    ) {
        self.title = title
        self.content = content
        self.patternGaugeStitches = patternGaugeStitches
        self.patternGaugeRows = patternGaugeRows
        self.gaugeUnit = gaugeUnit
        self.notes = notes
        self.createdAt = Date()
    }
}

enum GaugeUnit: String, Codable, CaseIterable {
    case per10cm = "per 10 cm"
    case per4inches = "per 4 inches"
}
