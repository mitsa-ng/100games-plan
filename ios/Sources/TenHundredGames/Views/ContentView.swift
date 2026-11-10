import SwiftUI
import TenHundredGames

struct ContentView: View {
    @EnvironmentObject private var app: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                if app.isOnboardingComplete {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                route.destination
            }
            .sheet(isPresented: $app.showingSettings) {
                SettingsView()
            }
        }
    }
}
