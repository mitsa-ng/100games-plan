import SwiftUI
import TenHundredGames

struct GameScreenView: View {
    let gameId: GameId
    @EnvironmentObject private var app: AppViewModel

    var body: some View {
        Group {
            switch gameId {
            case .game2048:
                Game2048View(viewModel: Game2048ViewModel(app: app))
            case .tetris:
                TetrisView(viewModel: TetrisViewModel(app: app))
            case .snake:
                SnakeView(viewModel: SnakeViewModel(app: app))
            case .breakout:
                BreakoutView(viewModel: BreakoutViewModel(app: app))
            case .minesweeper:
                MinesweeperView(viewModel: MinesweeperViewModel(app: app))
            case .memory:
                MemoryView(viewModel: MemoryViewModel(app: app))
            case .sudoku:
                SudokuView(viewModel: SudokuViewModel(app: app))
            case .ticTacToe:
                TicTacToeView(viewModel: TicTacToeViewModel(app: app))
            case .fifteenPuzzle:
                FifteenPuzzleView(viewModel: FifteenPuzzleViewModel(app: app))
            case .reaction:
                ReactionView(viewModel: ReactionViewModel(app: app))
            case .dino:
                DinoView(viewModel: DinoViewModel(app: app))
            case .ballBattle:
                BallBattleView(viewModel: BallBattleViewModel(app: app))
            case .eatcat:
                EatcatView(viewModel: EatcatViewModel(app: app))
            }
        }
        .onAppear {
            // ViewModel 已在初始化時建立，startNewGame 由各 View 的 .onAppear 呼叫
        }
    }
}

// 各 ViewModel 的 init 都接受 app 參數，無需類型擦除包裝器
