import SwiftUI

struct DinoView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: DinoViewModel

    var body: some View {
        GameScaffold(title: "谷歌小恐龙", score: viewModel.score, onPause: {}) {
            Canvas { context, size in
                // 地面
                let groundY = size.height * 0.8
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: 0, y: groundY))
                    p.addLine(to: CGPoint(x: size.width, y: groundY))
                }, with: .color(.black), lineWidth: 4)

                // 恐龍
                let dinoRect = CGRect(x: 60, y: groundY + viewModel.engine.dinoY - 40, width: 40, height: 40)
                context.fill(Path(dinoRect), with: .color(.green))

                // 障礙物
                for obstacle in viewModel.engine.obstacles {
                    let obsRect = CGRect(x: obstacle.x, y: groundY - obstacle.height, width: obstacle.width, height: obstacle.height)
                    context.fill(Path(obsRect), with: .color(.brown))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(TapGesture().onEnded {
                viewModel.jump()
            })

            if viewModel.isGameOver {
                GameOverView(score: viewModel.score, onRestart: {
                    viewModel.startNewGame()
                })
            }
        }
        .padding(24)
    }
}
