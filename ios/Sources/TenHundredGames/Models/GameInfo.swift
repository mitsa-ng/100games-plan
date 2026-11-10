import Foundation

struct GameInfo: Codable, Hashable, Sendable {
    let id: GameId
    let name: String
    let tagline: String
    let rules: [String]
    let category: GameCategory
    var lowerScoreIsBetter: Bool = false
}
