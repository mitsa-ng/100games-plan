import SwiftUI
import TenHundredGames

struct TicTacToeView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: TicTacToeViewModel

    var body: some View {
        GameScaffold(title: "井字棋", score: viewModel.score, onPause: {}) {
            VStack(spacing: 20) {
                Picker("AI 難度", selection: $viewModel.aiLevel) {
                    ForEach(TicTacToeAI.allCases, id: \.self) { level in
                        Text(level.label).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Canvas { context, size in
                    let cellSize = min(size.width, size.height) / 3
                    let originX = (size.width - cellSize * 3) / 2
                    let originY = (size.height - cellSize * 3) / 2

                    // 線條
                    let lineWidth: CGFloat = 4
                    for i in 1...2 {
                        context.stroke(Path { p in
                            p.move(to: CGPoint(x: originX + cellSize * CGFloat(i), y: originY))
                            p.addLine(to: CGPoint(x: originX + cellSize * CGFloat(i), y: originY + cellSize * 3))
                        }, with: .color(.primary), lineWidth: lineWidth)
                        context.stroke(Path { p in
                            p.move(to: CGPoint(x: originX, y: originY + cellSize * CGFloat(i)))
                            p.addLine(to: CGPoint(x: originX + cellSize * 3, y: originY + cellSize * CGFloat(i)))
                        }, with: .color(.primary), lineWidth: lineWidth)
                    }

                    // X / O
                    for index in 0..<9 {
                        let row = index / 3
                        let col = index % 3
                        let x = originX + cellSize * CGFloat(col) + cellSize / 2
                        let y = originY + cellSize * CGFloat(row) + cellSize / 2
                        let value = viewModel.engine.cellAt(index)
                        if value == TicTacToeEngine.player {
                            context.stroke(Path { p in
                                p.addEllipse(in: CGRect(x: x - 25, y: y - 25, width: 50, height: 50))
                            }, with: .color(.blue), lineWidth: 6)
                        } else if value == TicTacToeEngine.ai {
                            context.stroke(Path { p in
                                p.move(to: CGPoint(x: x - 25, y: y - 25))
                                p.addLine(to: CGPoint(x: x + 25, y: y + 25))
                                p.move(to: CGPoint(x: x + 25, y: y - 25))
                                p.addLine(to: CGPoint(x: x - 25, y: y + 25))
                            }, with: .color(.red), lineWidth: 6)
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            let cellSize = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 3
                            // 簡化：使用點擊而非拖曳
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            // 需要座標，TapGesture 沒有座標，使用下方的按鈕網格
                        }
                )

                // 替代：按鈕網格（更可靠）
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(0..<9, id: \.self) { index in
                        Button {
                            viewModel.play(at: index)
                        } label: {
                            let value = viewModel.engine.cellAt(index)
                            Group {
                                if value == TicTacToeEngine.player {
                                    Image(systemName: "circle.fill").font(.system(size: 40)).foregroundStyle(.blue)
                                } else if value == TicTacToeEngine.ai {
                                    Image(systemName: "xmark").font(.system(size: 40)).foregroundStyle(.red)
                                } else {
                                    Color.clear
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: 80)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(viewModel.engine.board[index] != 0 || viewModel.isGameOver)
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
