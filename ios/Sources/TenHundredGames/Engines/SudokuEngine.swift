import Foundation

struct SudokuCell: Codable, Hashable, Sendable, Identifiable {
    let id = UUID()
    var row: Int
    var col: Int
    var value: Int = 0          // 0 = 空
    var given: Bool = false     // 是否為題目給定
    var isSelected: Bool = false
    var isError: Bool = false
}

struct SudokuSnapshot: Codable, Hashable, Sendable {
    var cells: [SudokuCell] = []
    var moves: Int = 0
    var timeSeconds: Int = 0
    var isGameOver: Bool = false
    var isWon: Bool = false
}

final class SudokuEngine: ObservableObject {
    @Published private(set) var cells: [SudokuCell] = []
    @Published private(set) var moves: Int = 0
    @Published private(set) var timeSeconds: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var isWon: Bool = false

    private var random = SystemRandomNumberGenerator()

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.random = random
        newGame(difficulty: .easy)
    }

    convenience init(snapshot: SudokuSnapshot, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.init(random: random)
        self.cells = snapshot.cells
        self.moves = snapshot.moves
        self.timeSeconds = snapshot.timeSeconds
        self.isGameOver = snapshot.isGameOver
        self.isWon = snapshot.isWon
    }

    func newGame(difficulty: SudokuDifficulty = .easy) {
        cells = []
        for row in 0..<9 {
            for col in 0..<9 {
                cells.append(SudokuCell(row: row, col: col))
            }
        }
        generatePuzzle(difficulty: difficulty)
        moves = 0
        timeSeconds = 0
        isGameOver = false
        isWon = false
    }

    private func generatePuzzle(difficulty: SudokuDifficulty) {
        // 生成一個完成的數獨
        var board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        fillDiagonal(&board)
        solveSudoku(&board)

        // 挖空
        let removeCount: Int
        switch difficulty {
        case .easy: removeCount = 30
        case .medium: removeCount = 45
        case .hard: removeCount = 60
        }

        var removed = 0
        while removed < removeCount {
            let r = Int.random(in: 0..<9)
            let c = Int.random(in: 0..<9)
            if board[r][c] != 0 {
                board[r][c] = 0
                removed += 1
            }
        }

        for row in 0..<9 {
            for col in 0..<9 {
                let index = row * 9 + col
                cells[index].value = board[row][col]
                cells[index].given = board[row][col] != 0
            }
        }
    }

    private func fillDiagonal(_ board: inout [[Int]]) {
        for i in stride(from: 0, to: 9, by: 3) {
            fillBox(&board, row: i, col: i)
        }
    }

    private func fillBox(_ board: inout [[Int]], row: Int, col: Int) {
        for r in 0..<3 {
            for c in 0..<3 {
                var num: Int
                repeat {
                    num = Int.random(in: 1...9)
                } while !isSafe(board, row: row + r, col: col + c, num: num)
                board[row + r][col + c] = num
            }
        }
    }

    private func isSafe(_ board: [[Int]], row: Int, col: Int, num: Int) -> Bool {
        // 行
        for c in 0..<9 where board[row][c] == num { return false }
        // 列
        for r in 0..<9 where board[r][col] == num { return false }
        // 宫
        let boxRow = row - row % 3
        let boxCol = col - col % 3
        for r in 0..<3 {
            for c in 0..<3 {
                if board[boxRow + r][boxCol + c] == num { return false }
            }
        }
        return true
    }

    private func solveSudoku(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 where board[row][col] == 0 {
                for num in 1...9 {
                    if isSafe(board, row: row, col: col, num: num) {
                        board[row][col] = num
                        if solveSudoku(&board) { return true }
                        board[row][col] = 0
                    }
                }
                return false
            }
        }
        return true
    }

    func setValue(row: Int, col: Int, value: Int) {
        guard !isGameOver, !isWon else { return }
        guard let index = cells.firstIndex(where: { $0.row == row && $0.col == col }) else { return }
        guard !cells[index].given else { return }

        var cell = cells[index]
        cell.value = value
        cells[index] = cell
        moves += 1
        checkWin()
    }

    private func checkWin() {
        // 檢查所有格子都填滿且正確
        var board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        for cell in cells {
            board[cell.row][cell.col] = cell.value
        }

        guard !board.contains(where: { $0.contains(0) }) else { return }

        // 驗證每行每列每宮
        for r in 0..<9 {
            var seen = Set<Int>()
            for c in 0..<9 { seen.insert(board[r][c]) }
            if seen.count != 9 { return }
        }
        for c in 0..<9 {
            var seen = Set<Int>()
            for r in 0..<9 { seen.insert(board[r][c]) }
            if seen.count != 9 { return }
        }
        for br in stride(from: 0, to: 9, by: 3) {
            for bc in stride(from: 0, to: 9, by: 3) {
                var seen = Set<Int>()
                for r in 0..<3 {
                    for c in 0..<3 {
                        seen.insert(board[br + r][bc + c])
                    }
                }
                if seen.count != 9 { return }
            }
        }

        isWon = true
        isGameOver = true
    }

    func snapshot() -> SudokuSnapshot {
        SudokuSnapshot(cells: cells, moves: moves, timeSeconds: timeSeconds,
                       isGameOver: isGameOver, isWon: isWon)
    }
}

enum SudokuDifficulty: String, CaseIterable, Codable, Sendable {
    case easy, medium, hard
    var label: String {
        switch self {
        case .easy: return "简单"
        case .medium: return "中等"
        case .hard: return "困难"
        }
    }
}
