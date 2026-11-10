import SwiftUI
import TenHundredGames

struct BreakoutView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: BreakoutViewModel
    @State private var paddleX: Double = 160

    var body: some View {
        GameScaffold(title: "打砖块", score: viewModel.score, onPause: {}) {
            Canvas { context, size in
                viewModel.screenWidth = Double(size.width)
                viewModel.screenHeight = Double(size.height)

                // 挡板
                let paddleW: Double = 90
                let paddleH: Double = 12
                let paddleY = size.height - 40
                let paddleRect = CGRect(x: paddleX - paddleW/2, y: paddleY, width: paddleW, height: paddleH)
                context.fill(Path(paddleRect), with: .color(.blue))

                // 小球
                let b = viewModel.engine.ball
                let ballRect = CGRect(x: b.x - b.radius, y: b.y - b.radius, width: b.radius*2, height: b.radius*2)
                context.fill(Path(ellipseIn: ballRect), with: .color(.red))

                // 磚塊
                let brickSize: Double = 40
                for brick in viewModel.engine.bricks where !brick.destroyed {
                    let bx = Double(brick.col) * (brickSize + 8) + 40
                    let by = Double(brick.row) * (brickSize + 8) + 60
                    let brect = CGRect(x: bx, y: by, width: brickSize, height: brickSize)
                    context.fill(Path(brect), with: .color(colorForRow(brick.row)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        paddleX = value.location.x
                        viewModel.updatePaddle(x: paddleX)
                    }
            )

            if viewModel.isGameOver || viewModel.engine.isWon {
                GameOverView(score: viewModel.score, onRestart: {
                    viewModel.startNewGame()
                })
            }
        }
        .padding(24)
    }

    private func colorForRow(_ row: Int) -> Color {
        [Color.red, Color.orange, Color.yellow, Color.green, Color.blue][row % 5]
    }
}
