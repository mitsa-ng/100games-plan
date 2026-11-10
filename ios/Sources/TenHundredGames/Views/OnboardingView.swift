import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var app: AppViewModel

    var body: some View {
        VStack(spacing: 32) {
            Text("100 Games")
                .font(.system(size: 40, weight: .bold, design: .rounded))
            Text("100个有趣的小游戏，完全离线，本地保存")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("开始") {
                app.isOnboardingComplete = true
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
        .padding(40)
        .background(AppBackground())
    }
}
