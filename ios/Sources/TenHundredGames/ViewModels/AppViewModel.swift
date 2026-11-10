import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {
    private let statsRepo: GameStatsRepository
    private let settingsRepo: SettingsRepository
    private let feedback = FeedbackManager.shared

    @Published var isOnboardingComplete: Bool = false
    @Published var showingSettings: Bool = false
    @Published var playerStats: PlayerStats = PlayerStats()
    @Published var appSettings: AppSettings = AppSettings()

    var effectiveColorScheme: ColorScheme? {
        appSettings.themeMode.colorScheme
    }

    init(statsRepo: GameStatsRepository = UserDefaultsGameStatsRepository(),
         settingsRepo: SettingsRepository = UserDefaultsSettingsRepository()) {
        self.statsRepo = statsRepo
        self.settingsRepo = settingsRepo
    }

    func load() async {
        async let stats = statsRepo.loadStats()
        async let settings = settingsRepo.loadSettings()
        self.playerStats = await stats
        self.appSettings = await settings
        self.isOnboardingComplete = true
    }

    func recordPlay(gameId: GameId, score: Int) {
        Task {
            await statsRepo.recordPlay(gameId: gameId, score: score)
            await load()
        }
    }

    func toggleFavorite(gameId: GameId) {
        Task {
            await statsRepo.toggleFavorite(gameId: gameId)
            await load()
        }
    }

    func isFavorite(_ gameId: GameId) -> Bool {
        // 同步回傳本地快取，避免 UI 等待
        playerStats.favorites.contains(gameId)
    }

    func updateSettings(_ settings: AppSettings) {
        appSettings = settings
        Task {
            await settingsRepo.saveSettings(settings)
        }
    }

    func playSound(_ sound: FeedbackSound) {
        guard appSettings.soundEnabled else { return }
        feedback.play(sound)
    }

    func haptic(_ type: FeedbackHaptic) {
        guard appSettings.hapticsEnabled else { return }
        feedback.haptic(type)
    }
}
