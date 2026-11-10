import Foundation

protocol SettingsRepository: AnyObject, Sendable {
    func loadSettings() async -> AppSettings
    func saveSettings(_ settings: AppSettings) async
}
