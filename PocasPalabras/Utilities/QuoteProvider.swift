import Foundation

struct Quote: Codable {
    let text: String
    let author: String
}

/// Provides a deterministic quote of the day from a bundled JSON file.
///
/// Selection uses a stable DJB2 hash of the date string so the same date
/// always yields the same quote, regardless of process restarts.
enum QuoteProvider {

    static func quoteOfTheDay(for date: Date = Date()) -> Quote {
        let quotes = loadQuotes()
        guard !quotes.isEmpty else {
            return Quote(text: "Live deliberately.", author: "Henry David Thoreau")
        }

        let dateString = Self.dateString(for: date)
        let hash = Self.djb2Hash(dateString)
        let index = hash % quotes.count
        return quotes[index]
    }

    // MARK: - Private

    private static func loadQuotes() -> [Quote] {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quotes = try? JSONDecoder().decode([Quote].self, from: data)
        else {
            return defaultQuotes
        }
        return quotes
    }

    /// Stable hash — deterministic across runs unlike Swift's `Hasher`.
    private static func djb2Hash(_ string: String) -> Int {
        var hash: UInt64 = 5381
        for byte in string.utf8 {
            hash = ((hash &<< 5) &+ hash) &+ UInt64(byte)
        }
        return Int(hash % UInt64(Int.max))
    }

    private static func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    /// Fallback quotes in case the JSON file can't be loaded.
    private static let defaultQuotes: [Quote] = [
        Quote(text: "The unexamined life is not worth living.", author: "Socrates"),
        Quote(text: "Live as if you were to die tomorrow. Learn as if you were to live forever.", author: "Mahatma Gandhi"),
        Quote(text: "In the middle of every difficulty lies opportunity.", author: "Albert Einstein"),
    ]
}
