import SwiftUI
import TenHundredGames

struct Game2048View: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: Game2048ViewModel
    @State private var dragStart: CGPoint? = nil

    var body: some View {
        GameScaffold(title: "2048", score: viewModel.score, onPause: {}) {
            VStack(spacing: 16) {
                Canvas { context, size in
                    let tileSize: CGFloat = 60
                    let spacing: CGFloat = 8
                    let boardSize = CGFloat(Game2048Engine.boardSize)
                    let total = boardSize * tileSize + (boardSize + 1) * spacing
                    let originX = (size.width - total) / 2
                    let originY = (size.height - total) / 2

                    // 背景
                    let boardRect = CGRect(x: originX, y: originY, width: total, height: total)
                    context.fill(Path(boardRect), with: .color(Color(red: 0.88, green: 0.86, blue: 0.82)))

                    // 方塊
                    for tile in viewModel.engine.boardTiles {
                        let x = originX + spacing + CGFloat(tile.col) * (tileSize + spacing)
                        let y = originY + spacing + CGFloat(tile.row) * (tileSize + spacing)
                        let rect = CGRect(x: x, y: y, width: tileSize, height: tileSize)
                        let color: Color = colorForValue(tile.value)
                        let path = Path(roundedRect: rect, cornerRadius: 8)
                        context.fill(path, with: .color(color))
                        context.draw(
                            Text("\(tile.value)")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(tile.value > 4 ? .white : Color(red: 0.15, green: 0.14, blue: 0.13)),
                            at: CGPoint(x: x + tileSize/2, y: y + tileSize/2)
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            if dragStart == nil { dragStart = value.startLocation }
                        }
                        .onEnded { value in
                            guard let start = dragStart else { return }
                            dragStart = nil
                            let dx = value.location.x - start.x
                            let dy = value.location.y - start.y
                            if abs(dx) > abs(dy) {
                                viewModel.move(dx > 0 ? .right : .left)
                            } else {
                                viewModel.move(dy > 0 ? .down : .up)
                            }
                        }
                )

                Button("撤销") {
                    viewModel.undo()
                }
                .disabled(!viewModel.engine.canUndo)
                .font(.headline)
                .foregroundStyle(viewModel.engine.canUndo ? .blue : .secondary)

                if viewModel.isGameOver {
                    GameOverView(score: viewModel.score, onRestart: {
                        viewModel.startNewGame()
                    })
                }
            }
            .padding(24)
        }
    }

    private func colorForValue(_ value: Int) -> Color {
        switch value {
        case 2: return Color(red: 0.97, green: 0.94, blue: 0.87)
        case 4: return Color(red: 0.94, green: 0.89, blue: 0.72)
        case 8: return Color(red: 0.95, green: 0.74, blue: 0.46)
        case 16: return Color(red: 0.98, green: 0.62, blue: 0.34)
        case 32: return Color(red: 0.97, green: 0.51, blue: 0.23)
        case 64: return Color(red: 0.96, green: 0.44, blue: 0.25)
        case 128: return Color(red: 0.94, green: 0.66, blue: 0.30)
        case 256: return Color(red: 0.93, green: 0.60, blue: 0.27)
        case 512: return Color(red: 0.93, green: 0.56, blue: 0.25)
        case 1024: return Color(red: 0.92, green: 0.52, blue: 0.24)
        default: return Color(red: 0.91, green: 0.49, blue: 0.23)
        }
    }
}
