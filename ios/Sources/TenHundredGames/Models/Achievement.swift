import Foundation

enum Achievement: String, CaseIterable, Codable, Hashable, Sendable {
    case firstGame = "first_game"
    case fivePlays = "five_plays"
    case twentyPlays = "twenty_plays"
    case fiftyPlays = "fifty_plays"
    case favoriteThree = "favorite_three"
    case favoriteAll = "favorite_all"
    case explorerFive = "explorer_five"
    case explorerAll = "explorer_all"

    var title: String {
        switch self {
        case .firstGame: return "初次登场"
        case .fivePlays: return "渐入佳境"
        case .twentyPlays: return "百玩不厌"
        case .fiftyPlays: return "百战不殆"
        case .favoriteThree: return "收藏新手"
        case .favoriteAll: return "收藏大师"
        case .explorerFive: return "多面玩家"
        case .explorerAll: return "十项全能"
        }
    }

    var description: String {
        switch self {
        case .firstGame: return "完成第一局游戏"
        case .fivePlays: return "累计完成 5 局游戏"
        case .twentyPlays: return "累计完成 20 局游戏"
        case .fiftyPlays: return "累计完成 50 局游戏"
        case .favoriteThree: return "收藏 3 款游戏"
        case .favoriteAll: return "收藏全部游戏"
        case .explorerFive: return "游玩 5 款不同的游戏"
        case .explorerAll: return "游玩全部游戏"
        }
    }

    var target: Int {
        switch self {
        case .firstGame: return 1
        case .fivePlays: return 5
        case .twentyPlays: return 20
        case .fiftyPlays: return 50
        case .favoriteThree: return 3
        case .favoriteAll: return GameCatalog.all.count
        case .explorerFive: return 5
        case .explorerAll: return GameCatalog.all.count
        }
    }

    func currentValue(stats: PlayerStats) -> Int {
        switch self {
        case .firstGame, .fivePlays, .twentyPlays, .fiftyPlays:
            return stats.totalPlays
        case .favoriteThree, .favoriteAll:
            return stats.favorites.count
        case .explorerFive, .explorerAll:
            return stats.playedGameCount
        }
    }

    func progress(for stats: PlayerStats) -> AchievementProgress {
        let current = currentValue(stats: stats)
        return AchievementProgress(
            achievement: self,
            current: current
        )
    }
}

struct AchievementProgress: Codable, Hashable, Sendable {
    let achievement: Achievement
    let current: Int

    var target: Int { achievement.target }
    var isUnlocked: Bool { current >= target }
    var fraction: Float {
        let t = Float(target)
        guard t > 0 else { return 1 }
        return (Float(current) / t).clamped(to: 0...1)
    }
}

private extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
