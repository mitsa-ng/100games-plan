import SwiftUI
import TenHundredGames

struct ReactionView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: ReactionViewModel

    var body: some View {
        GameScaffold(title: "反应力挑战", score: viewModel.score, onPause: {}) {
            VStack(spacing: 24) {
                Text(viewModel.engine.isWaiting ? "等待变色..." : viewModel.engine.isShowingColor ? "🔴 点击！" : "第 \(viewModel.engine.round) 轮")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(viewModel.engine.isShowingColor ? .red : .primary)

                if let t = viewModel.currentReaction {
                    Text("\(t) ms").font(.largeTitle).fontWeight(.bold)
                }

                Button(viewModel.engine.isWaiting || viewModel.engine.isShowingColor ? "不要点击" : "开始") {
                    if viewModel.engine.isWaiting || viewModel.engine.isShowingColor {
                        viewModel.onFalseStart()
                    } else {
                        viewModel.startNewGame()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isGameOver)

                if viewModel.isGameOver {
                    GameOverView(score: viewModel.score, onRestart: {
                        viewModel.startNewGame()
                    })
                }
            }
            .padding(24)
            .background(AppBackground())
        }
    }
}
