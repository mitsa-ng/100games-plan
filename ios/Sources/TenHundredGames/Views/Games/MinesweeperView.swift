import SwiftUI
import TenHundredGames

struct MinesweeperView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: MinesweeperViewModel
    @State private var showingSetup = true

    var body: some View {
        ZStack {
            if showingSetup {
                setupView
            } else {
                gameView
            }
        }
    }

    var setupView: some View {
        VStack(spacing: 24) {
            Text("扫雷").font(.largeTitle).fontWeight(.bold)
            Button("开始（9×9，10 雷）") { showingSetup = false }
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(AppBackground())
    }

    var gameView: some View {
        GameScaffold(title: "扫雷", score: viewModel.score, onPause: {}) {
            VStack(spacing: 2) {
                ForEach(0..<9, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<9, id: \.self) { col in
                            Button {
                                viewModel.reveal(at: row, col: col)
                            } label: {
                                cellView(row: row, col: col)
                            }
                            .frame(width: 36, height: 36)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                    viewModel.toggleFlag(at: row, col: col)
                                }
                            )
                        }
                    }
                }
            }
            .padding(24)

            if viewModel.isGameOver {
                GameOverView(score: viewModel.score, onRestart: {
                    viewModel.startNewGame()
                })
            }
        }
    }

    private func cellView(row: Int, col: Int) -> some View {
        Group {
            if let cell = viewModel.engine.cells.first(where: { $0.row == row && $0.col == col }) {
                if cell.isFlagged {
                    Image(systemName: "flag.fill").foregroundStyle(.orange).font(.caption)
                } else if cell.isRevealed {
                    if cell.isMine {
                        Image(systemName: "fill.fill").foregroundStyle(.red).font(.caption)
                    } else if cell.adjacentMines > 0 {
                        Text("\(cell.adjacentMines)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(colorForNumber(cell.adjacentMines))
                    } else {
                        Color.clear
                    }
                } else {
                    Color.clear
                }
            } else {
                Color.clear
            }
        }
    }

    private func colorForNumber(_ n: Int) -> Color {
        [Color.blue, Color.green, Color.red, Color.purple, Color.orange, Color.teal, Color.mint, Color.pink][n-1]
    }
}
