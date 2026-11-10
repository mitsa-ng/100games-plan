import SwiftUI

struct TetrisView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: TetrisViewModel

    var body: some View {
        GameScaffold(title: "俄罗斯方块", score: viewModel.score, onPause: {}) {
            Canvas { context, size in
                let cellSize = min(size.width / 12, size.height / 22)
                let originX = (size.width - cellSize * 10) / 2
                let originY = (size.height - cellSize * 20) / 2

                // 格子
                for row in 0..<20 {
                    for col in 0..<10 {
                        let val = viewModel.engine.grid[row][col]
                        if val != 0 {
                            let rect = CGRect(x: originX + cellSize * CGFloat(col),
                                              y: originY + cellSize * CGFloat(row),
                                              width: cellSize, height: cellSize)
                            context.fill(Path(rect), with: .color(colorForType(val - 1)))
                        }
                    }
                }

                // 當前方塊
                if let piece = viewModel.engine.current {
                    for (r, c) in piece.cells {
                        let nr = viewModel.engine.currentPos.0 + r
                        let nc = viewModel.engine.currentPos.1 + c
                        guard nr >= 0, nr < 20, nc >= 0, nc < 10 else { continue }
                        let rect = CGRect(x: originX + cellSize * CGFloat(nc),
                                          y: originY + cellSize * CGFloat(nr),
                                          width: cellSize, height: cellSize)
                        context.fill(Path(rect), with: .color(piece.type.color))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onEnded { value in
                        let dx = value.location.x - value.startLocation.x
                        let dy = value.location.y - value.startLocation.y
                        if abs(dx) > abs(dy) {
                            dx > 0 ? viewModel.moveRight() : viewModel.moveLeft()
                        } else {
                            dy > 0 ? viewModel.moveDown() : viewModel.rotate()
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    viewModel.hardDrop()
                }
            )

            VStack {
                HStack {
                    Text("分數：\(viewModel.score)").font(.headline)
                    Spacer()
                    Text("等級：\(viewModel.engine.level)").font(.headline)
                }
                .padding(.horizontal, 24)

                HStack(spacing: 30) {
                    Button("←") { viewModel.moveLeft() }.font(.title2)
                    Button("↻") { viewModel.rotate() }.font(.title2)
                    Button("→") { viewModel.moveRight() }.font(.title2)
                }

                Button("硬落") { viewModel.hardDrop() }
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
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

    private func colorForType(_ index: Int) -> Color {
        let colors: [Color] = [.cyan, .blue, .orange, .yellow, .green, .purple, .red]
        return colors[index % colors.count]
    }
}
