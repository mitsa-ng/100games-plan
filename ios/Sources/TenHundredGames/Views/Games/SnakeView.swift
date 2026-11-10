import SwiftUI
import TenHundredGames

struct SnakeView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: SnakeViewModel
    @State private var dragStart: CGPoint? = nil
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
            Text("贪吃蛇").font(.largeTitle).fontWeight(.bold)
            Text("难度").font(.headline)
            Picker("", selection: $viewModel.difficulty) {
                ForEach(SnakeDifficulty.allCases, id: \.self) { d in Text(d.label).tag(d) }
            }
            .pickerStyle(.segmented)
            Toggle("穿墙", isOn: $viewModel.wrapAround)
            Button("开始") { showingSetup = false }
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(AppBackground())
    }

    var gameView: some View {
        GameScaffold(title: "贪吃蛇", score: viewModel.score, onPause: {}) {
            Canvas { context, size in
                let cols = CGFloat(SnakeEngine.columns)
                let rows = CGFloat(SnakeEngine.rows)
                let cellW = size.width / cols
                let cellH = size.height / rows

                // 蛇身
                for cell in viewModel.engine.snakeBody {
                    let rect = CGRect(
                        x: CGFloat(cell.col) * cellW,
                        y: CGFloat(cell.row) * cellH,
                        width: cellW, height: cellH
                    )
                    context.fill(Path(rect), with: .color(.green))
                }

                // 食物
                let f = viewModel.engine.currentFood
                let fRect = CGRect(
                    x: CGFloat(f.col) * cellW,
                    y: CGFloat(f.row) * cellH,
                    width: cellW, height: cellH
                )
                context.fill(Path(fRect), with: .color(.red))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        if dragStart == nil { dragStart = value.startLocation }
                    }
                    .onEnded { value in
                        guard let start = dragStart else { return }
                        dragStart = nil
                        let dx = value.location.x - start.x
                        let dy = value.location.y - start.y
                        if abs(dx) > abs(dy) {
                            viewModel.turn(dx > 0 ? .right : .left)
                        } else {
                            viewModel.turn(dy > 0 ? .down : .up)
                        }
                    }
            )

            if viewModel.isGameOver {
                GameOverView(score: viewModel.score, onRestart: {
                    viewModel.startNewGame()
                })
            }
        }
        .padding(24)
    }
}
