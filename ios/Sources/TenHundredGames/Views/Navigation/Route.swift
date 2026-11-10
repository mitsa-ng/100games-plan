import SwiftUI
import TenHundredGames

enum Route: Hashable, Sendable {
    case home
    case gameDetail(GameId)
    case gameScreen(GameId)
    case settings
    case achievements

    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            HomeView()
        case .gameDetail(let id):
            GameDetailView(gameId: id)
        case .gameScreen(let id):
            GameScreenView(gameId: id)
        case .settings:
            SettingsView()
        case .achievements:
            AchievementsView()
        }
    }
}
