import SwiftUI
import TenHundredGames

struct SudokuView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: SudokuViewModel
    @State private var selectedIndex: Int? = nil

    var body: some View {
        GameScaffold(title: "数独", score: viewModel.score, onPause: {}) {
            VStack(spacing: 12) {
                Canvas { context, size in
                    let cellSize = min(size.width, size.height) / 9
                    let originX = (size.width - cellSize * 9) / 2
                    let originY = (size.height - cellSize * 9) / 2

                    for cell in viewModel.engine.cells {
                        let x = originX + cellSize * CGFloat(cell.col)
                        let y = originY + cellSize * CGFloat(cell.row)
                        let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)

                        if cell.given {
                            context.fill(Path(rect), with: .color(Color(red: 0.92, green: 0.94, blue: 0.96)))
                        }
                        if let selected = selectedIndex,
                           viewModel.engine.cells[selected].row == cell.row ||
                           viewModel.engine.cells[selected].col == cell.col {
                            context.fill(Path(rect), with: .color(Color.blue.opacity(0.15)))
                        }

                        // 宮邊界
                        if cell.col % 3 == 0 {
                            context.stroke(Path(CGRect(x: x, y: y, width: 2, height: cellSize * 9)), with: .color(.black), lineWidth: 2)
                        }
                        if cell.row % 3 == 0 {
                            context.stroke(Path(CGRect(x: x, y: y, width: cellSize * 9, height: 2)), with: .color(.black), lineWidth: 2)
                        }

                        if cell.value != 0 {
                            context.draw(
                                Text("\(cell.value)")
                                    .font(.system(size: cellSize * 0.5, weight: cell.given ? .bold : .medium, design: .rounded))
                                    .foregroundStyle(cell.given ? .primary : Color.blue),
                                at: CGPoint(x: x + cellSize/2, y: y + cellSize/2)
                            )
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .gesture(
                    TapGesture().onEnded {
                        // 簡化：點擊網格，此處略過座標計算
                    }
                )

                // 數字鍵盤
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 9), spacing: 6) {
                    ForEach(1...9, id: \.self) { num in
                        Button {
                            // 需要選中的 cell，簡化略過
                        } label: {
                            Text("\(num)")
                                .font(.headline)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: 44)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
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
