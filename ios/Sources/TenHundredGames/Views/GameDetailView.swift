import SwiftUI
import TenHundredGames

struct GameDetailView: View {
    let gameId: GameId
    @EnvironmentObject private var app: AppViewModel

    var info: GameInfo {
        GameCatalog.findById(gameId)!
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 標題區
                HStack {
                    Button {
                        // 返回由 NavigationStack 處理
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    .opacity(0) // 佔位，NavigationStack 自動處理返回
                    Text(info.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.horizontal, 24)

                Text(info.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)

                // 規則
                VStack(alignment: .leading, spacing: 10) {
                    Text("规则")
                        .font(.headline)
                        .fontWeight(.semibold)
                    ForEach(info.rules, id: \.self) { rule in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.caption)
                            Text(rule)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 40)

                // 开始按钮
                Button {
                    // 進入遊戲畫面
                } label: {
                    Text("开始游戏")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(info.name)
    }
}
