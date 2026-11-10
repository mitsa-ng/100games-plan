import SwiftUI
import TenHundredGames

struct FifteenPuzzleView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: FifteenPuzzleViewModel

    var body: some View {
        GameScaffold(title: "数字华容道", score: viewModel.score, onPause: {}) {
            VStack(spacing: 12) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                    ForEach(0..<16, id: \.self) { index in
                        let value = viewModel.engine.tiles[index]
                        if value == 0 {
                            Color.clear.frame(height: 70)
                        } else {
                            Button {
                                viewModel.moveTile(at: index)
                            } label: {
                                Text("\(value)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: 70)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal, 24)

                if viewModel.isGameOver {
                    GameOverView(score: viewModel.score, onRestart: {
                        viewModel.startNewGame()
                    })
                }
            }
            .padding(24)
        }
    }
}
