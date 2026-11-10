import SwiftUI
import TenHundredGames

struct BallBattleView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: BallBattleViewModel

    var body: some View {
        GameScaffold(title: "小球对对碰", score: viewModel.score, onPause: {}) {
            GeometryReader { geometry in
                let size = geometry.size

                Canvas { context, _ in
                    // 玩家球
                    let p = viewModel.engine.playerBall
                    let pRect = CGRect(x: p.x - p.radius, y: p.y - p.radius, width: p.radius * 2, height: p.radius * 2)
                    context.fill(Path(ellipseIn: pRect), with: .color(.blue))

                    // AI 球
                    let a = viewModel.engine.aiBall
                    let aRect = CGRect(x: a.x - a.radius, y: a.y - a.radius, width: a.radius * 2, height: a.radius * 2)
                    context.fill(Path(ellipseIn: aRect), with: .color(.red))

                    // HP 條
                    context.fill(Path(CGRect(x: 40, y: 40, width: 200 * p.hp / p.maxHp, height: 10)), with: .color(.green))
                    context.fill(Path(CGRect(x: size.width - 240, y: 40, width: 200 * a.hp / a.maxHp, height: 10)), with: .color(.orange))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.updatePlayerPosition(x: value.location.x, y: value.location.y,
                                                           screenWidth: Double(size.width),
                                                           screenHeight: Double(size.height))
                        }
                )
            }

            if viewModel.isGameOver {
                GameOverView(score: viewModel.score, onRestart: {
                    viewModel.startNewGame()
                })
            }
        }
        .padding(24)
    }
}
