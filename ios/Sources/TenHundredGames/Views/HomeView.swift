import SwiftUI
import TenHundredGames

struct HomeView: View {
    @EnvironmentObject private var app: AppViewModel

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                // 標題
                HStack {
                    Text("100 Games")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                    Button {
                        app.showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // 搜尋/最近
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // 最近游玩
                        if !app.playerStats.recentGameIds.isEmpty {
                            SectionHeader(title: "最近游玩")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(app.playerStats.recentGameIds.prefix(5), id: \.self) { gameId in
                                        if let info = GameCatalog.findById(gameId) {
                                            GameCardView(info: info, isFavorite: app.isFavorite(gameId)) {
                                                app.toggleFavorite(gameId: gameId)
                                            } onPlay: {
                                                app.recordPlay(gameId: gameId, score: 0)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // 全部遊戲
                        SectionHeader(title: "全部游戏")
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            ForEach(GameCatalog.all, id: \.id) { info in
                                GameCardView(info: info, isFavorite: app.isFavorite(info.id)) {
                                    app.toggleFavorite(gameId: info.id)
                                } onPlay: {
                                    app.recordPlay(gameId: info.id, score: 0)
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // 成就簡述
                        SectionHeader(title: "成就")
                        let unlocked = Achievement.allCases.filter {
                            $0.progress(for: app.playerStats).isUnlocked
                        }.count
                        let total = Achievement.allCases.count
                        Text("\(unlocked) / \(total) 项成就已解锁")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct GameCardView: View {
    let info: GameInfo
    let isFavorite: Bool
    let onFavorite: () -> Void
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .frame(height: 120)
                    .overlay(
                        Text(info.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    )

                Button {
                    onFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundStyle(isFavorite ? .red : .secondary)
                        .padding(8)
                        .background(Color(red: 0.97, green: 0.97, blue: 0.96).opacity(0.8))
                        .clipShape(Circle())
                }
                .offset(x: 8, y: 8)
            }

            Text(info.tagline)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onPlay()
        }
    }
}

struct AppBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Group {
            if colorScheme == .dark {
                Color(red: 0.10, green: 0.11, blue: 0.14)
            } else {
                Color(red: 0.97, green: 0.97, blue: 0.96)
            }
        }
        .ignoresSafeArea()
    }
}
