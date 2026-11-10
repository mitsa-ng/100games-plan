import Foundation

actor UserDefaultsSettingsRepository: SettingsRepository {
    private let defaults = UserDefaults.standard
    private let settingsKey = "playbox_app_settings"

    func loadSettings() async -> AppSettings {
        guard let data = defaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    func saveSettings(_ settings: AppSettings) async {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: settingsKey)
    }
}
