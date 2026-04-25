import Foundation

struct GaugeMatch {
    let range: Range<String.Index>
    let originalValue: Int
    let adjustedValue: Int
    let type: MatchType

    enum MatchType {
        case stitches, rows, measurement
    }
}

struct GaugeParser {
    // Regex patterns for stitch counts (Danish + English)
    private static let stitchPatterns = [
        #"(\d+)\s*(?:masker|m\b)"#,
        #"(\d+)\s*(?:stitches|sts?)\b"#,
        #"(?:slå|cast\s+on|CO)\s+(\d+)"#,
        #"(?:opsaml|pick\s+up)\s+(\d+)"#,
    ]

    // Regex patterns for row counts
    private static let rowPatterns = [
        #"(\d+)\s*(?:rækker|r\b)"#,
        #"(\d+)\s*(?:rows?)\b"#,
        #"(?:strik|knit|purl|strik|hækl)\s+(\d+)"#,
        #"(?:gentag|repeat)\s+(?:\w+\s+){0,3}(\d+)\s+(?:gange|times)"#,
    ]

    // Measurement patterns (cm and inches)
    private static let measurementPatterns = [
        #"(\d+(?:[.,]\d+)?)\s*cm\b"#,
        #"(\d+(?:[.,]\d+)?)\s*(?:\"|\binches\b|\bin\b)"#,
    ]

    static func adjust(text: String, stitchFactor: Double, rowFactor: Double) -> AdjustedPattern {
        var result = text
        var replacements: [(original: String, adjusted: String, type: GaugeMatch.MatchType)] = []

        // Process in reverse order so ranges remain valid
        var allMatches: [(range: NSRange, value: Double, factor: Double, type: GaugeMatch.MatchType)] = []

        allMatches += findMatches(in: text, patterns: stitchPatterns, factor: stitchFactor, type: .stitches)
        allMatches += findMatches(in: text, patterns: rowPatterns, factor: rowFactor, type: .rows)
        allMatches += findMatches(in: text, patterns: measurementPatterns, factor: stitchFactor, type: .measurement)

        // Sort by location descending so we can replace without shifting indices
        let sorted = allMatches.sorted { $0.range.location > $1.range.location }

        var nsResult = result as NSString
        var changeLog: [(originalValue: String, adjustedValue: String, type: GaugeMatch.MatchType)] = []

        for match in sorted {
            let matchStr = nsResult.substring(with: match.range)
            let adjusted = applyFactor(to: matchStr, value: match.value, factor: match.factor, type: match.type)
            changeLog.append((matchStr, adjusted, match.type))
            nsResult = nsResult.replacingCharacters(in: match.range, with: adjusted) as NSString
        }

        return AdjustedPattern(
            originalText: text,
            adjustedText: nsResult as String,
            changes: changeLog.reversed().map { AdjustedPattern.Change(original: $0.originalValue, adjusted: $0.adjustedValue, type: $0.type) }
        )
    }

    private static func findMatches(
        in text: String,
        patterns: [String],
        factor: Double,
        type: GaugeMatch.MatchType
    ) -> [(range: NSRange, value: Double, factor: Double, type: GaugeMatch.MatchType)] {
        var results: [(range: NSRange, value: Double, factor: Double, type: GaugeMatch.MatchType)] = []

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { continue }
            let nsText = text as NSString
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            for match in matches {
                // Find the first capture group with a number
                for groupIndex in 1..<match.numberOfRanges {
                    let range = match.range(at: groupIndex)
                    guard range.location != NSNotFound else { continue }
                    let numStr = nsText.substring(with: range).replacingOccurrences(of: ",", with: ".")
                    if let value = Double(numStr), value > 0 {
                        results.append((range, value, factor, type))
                        break
                    }
                }
            }
        }

        // Remove duplicates by range location
        var seen = Set<Int>()
        return results.filter { seen.insert($0.range.location).inserted }
    }

    private static func applyFactor(to original: String, value: Double, factor: Double, type: GaugeMatch.MatchType) -> String {
        let adjusted = value * factor

        if type == .measurement {
            // Keep one decimal for measurements
            let rounded = (adjusted * 10).rounded() / 10
            let formatted = rounded.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(rounded))"
                : String(format: "%.1f", rounded)
            return original.replacingOccurrences(of: formatNumber(value), with: formatted)
        } else {
            // Round to nearest whole number for stitch/row counts
            let rounded = Int(adjusted.rounded())
            return original.replacingOccurrences(of: formatNumber(value), with: "\(rounded)")
        }
    }

    private static func formatNumber(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))"
            : String(value)
    }
}

struct AdjustedPattern {
    let originalText: String
    let adjustedText: String
    let changes: [Change]

    struct Change {
        let original: String
        let adjusted: String
        let type: GaugeMatch.MatchType
    }

    var hasChanges: Bool { !changes.isEmpty }
}
