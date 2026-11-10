import SwiftUI

struct GameScaffold<Content: View>: View {
    let title: String
    let score: Int
    let onPause: () -> Void
    @ViewBuilder let content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(score)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                content
            }
        }
    }
}

struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("游戏结束")
                .font(.title2)
                .fontWeight(.bold)
            Text("得分：\(score)")
                .font(.title)
                .fontWeight(.bold)
            Button("再来一局") {
                onRestart()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96).opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
