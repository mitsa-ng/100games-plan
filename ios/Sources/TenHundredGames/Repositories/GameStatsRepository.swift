import Foundation

protocol GameStatsRepository: AnyObject, Sendable {
    func loadStats() async -> PlayerStats
    func saveStats(_ stats: PlayerStats) async
    func recordPlay(gameId: GameId, score: Int) async
    func toggleFavorite(gameId: GameId) async
    func isFavorite(_ gameId: GameId) async -> Bool
}
