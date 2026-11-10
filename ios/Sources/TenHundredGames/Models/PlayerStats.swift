import Foundation

struct PlayerStats: Codable, Hashable, Sendable {
    var highScores: [GameId: Int] = [:]
    var playCounts: [GameId: Int] = [:]
    var favorites: Set<GameId> = []
    var recentGameIds: [GameId] = []

    var totalPlays: Int { playCounts.values.reduce(0, +) }

    var playedGameCount: Int { playCounts.filter { $0.value > 0 }.count }

    func highScore(for gameId: GameId) -> Int {
        highScores[gameId] ?? 0
    }

    func playCount(for gameId: GameId) -> Int {
        playCounts[gameId] ?? 0
    }
}
