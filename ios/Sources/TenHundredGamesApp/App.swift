import SwiftUI
import TenHundredGames

@main
struct TenHundredGamesApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .task {
                    await appViewModel.load()
                }
                .preferredColorScheme(appViewModel.effectiveColorScheme)
        }
    }
}
