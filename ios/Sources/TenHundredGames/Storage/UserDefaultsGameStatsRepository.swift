import Foundation

actor UserDefaultsGameStatsRepository: GameStatsRepository {
    private let defaults = UserDefaults.standard
    private let statsKey = "playbox_player_stats"

    func loadStats() async -> PlayerStats {
        guard let data = defaults.data(forKey: statsKey),
              let stats = try? JSONDecoder().decode(PlayerStats.self, from: data) else {
            return PlayerStats()
        }
        return stats
    }

    func saveStats(_ stats: PlayerStats) async {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        defaults.set(data, forKey: statsKey)
    }

    func recordPlay(gameId: GameId, score: Int) async {
        var stats = await loadStats()
        stats.playCounts[gameId, default: 0] += 1
        if score > stats.highScores[gameId, default: 0] {
            stats.highScores[gameId] = score
        }
        if !stats.recentGameIds.contains(gameId) {
            stats.recentGameIds.insert(gameId, at: 0)
            if stats.recentGameIds.count > 10 {
                stats.recentGameIds.removeLast()
            }
        } else {
            stats.recentGameIds.removeAll { $0 == gameId }
            stats.recentGameIds.insert(gameId, at: 0)
        }
        await saveStats(stats)
    }

    func toggleFavorite(gameId: GameId) async {
        var stats = await loadStats()
        if stats.favorites.contains(gameId) {
            stats.favorites.remove(gameId)
        } else {
            stats.favorites.insert(gameId)
        }
        await saveStats(stats)
    }

    func isFavorite(_ gameId: GameId) async -> Bool {
        let stats = await loadStats()
        return stats.favorites.contains(gameId)
    }
}
