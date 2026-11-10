import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var app: AppViewModel

    var body: some View {
        List {
            ForEach(Achievement.allCases, id: \.self) { achievement in
                let progress = achievement.progress(for: app.playerStats)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .font(.headline)
                            .foregroundStyle(progress.isUnlocked ? .primary : .secondary)
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack {
                        Text("\(progress.current) / \(progress.target)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        ProgressView(value: progress.fraction)
                    }
                    .frame(width: 120)
                    if progress.isUnlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .navigationTitle("成就")
    }
}
