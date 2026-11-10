import SwiftUI
import TenHundredGames

struct MemoryView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: MemoryViewModel

    var body: some View {
        GameScaffold(title: "记忆翻牌", score: viewModel.score, onPause: {}) {
            VStack(spacing: 16) {
                Text("步数：\(viewModel.engine.moves)")
                    .font(.headline)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                    ForEach(viewModel.engine.cards) { card in
                        Button {
                            viewModel.flipCard(id: card.id)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(card.isFaceUp || card.isMatched ? Color.white : Color.blue)
                                if card.isFaceUp || card.isMatched {
                                    Text(card.symbol).font(.system(size: 32))
                                }
                            }
                            .frame(height: 80)
                        }
                        .disabled(card.isMatched || viewModel.isGameOver)
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
