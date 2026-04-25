import Foundation

struct YarnEntry: Codable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let weightCategory: String
    let gaugeMin: Double
    let gaugeMax: Double
    let needleSize: String
    let fiber: String
    let metersPerHundredG: Int

    var gaugeMid: Double { (gaugeMin + gaugeMax) / 2 }

    var weightEnum: YarnWeight? {
        YarnWeight.allCases.first { $0.rawValue == weightCategory }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, brand
        case weightCategory = "weight_category"
        case gaugeMin = "gauge_min"
        case gaugeMax = "gauge_max"
        case needleSize = "needle_size"
        case fiber
        case metersPerHundredG = "meters_per_100g"
    }
}

@Observable
final class YarnDatabase {
    private(set) var yarns: [YarnEntry] = []

    static let shared = YarnDatabase()

    init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "yarns", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([YarnEntry].self, from: data)
        else { return }
        yarns = entries
    }

    func findAlternatives(for yarn: YarnEntry, tolerance: Double = 3.0) -> [ScoredYarn] {
        yarns
            .filter { $0.id != yarn.id }
            .compactMap { candidate -> ScoredYarn? in
                let gaugeDiff = abs(candidate.gaugeMid - yarn.gaugeMid)
                guard gaugeDiff <= tolerance else { return nil }
                let weightBonus: Double = candidate.weightCategory == yarn.weightCategory ? 0 : 1
                let score = gaugeDiff + weightBonus
                return ScoredYarn(yarn: candidate, score: score, gaugeDiff: gaugeDiff)
            }
            .sorted { $0.score < $1.score }
    }

    func findAlternativesForGauge(stitchesPer10cm: Double, tolerance: Double = 2.0) -> [ScoredYarn] {
        yarns
            .compactMap { candidate -> ScoredYarn? in
                let gaugeDiff = abs(candidate.gaugeMid - stitchesPer10cm)
                guard gaugeDiff <= tolerance else { return nil }
                return ScoredYarn(yarn: candidate, score: gaugeDiff, gaugeDiff: gaugeDiff)
            }
            .sorted { $0.score < $1.score }
    }

    func search(_ query: String) -> [YarnEntry] {
        guard !query.isEmpty else { return yarns }
        return yarns.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.brand.localizedCaseInsensitiveContains(query)
        }
    }
}

struct ScoredYarn: Identifiable {
    var id: String { yarn.id }
    let yarn: YarnEntry
    let score: Double
    let gaugeDiff: Double

    var matchDescription: String {
        if gaugeDiff < 0.5 { return "Perfekt match" }
        if gaugeDiff < 1.5 { return "Tæt match" }
        return "Lignende gauge"
    }
}
