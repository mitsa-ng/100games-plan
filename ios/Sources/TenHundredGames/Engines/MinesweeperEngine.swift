import Foundation

struct MineCell: Codable, Hashable, Sendable, Identifiable {
    let id = UUID()
    var row: Int
    var col: Int
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var adjacentMines: Int = 0
}

struct MinesweeperSnapshot: Codable, Hashable, Sendable {
    var cells: [MineCell] = []
    var rows: Int = 0
    var cols: Int = 0
    var mineCount: Int = 0
    var revealedCount: Int = 0
    var flaggedCount: Int = 0
    var isGameOver: Bool = false
    var isWon: Bool = false
    var firstMove: Bool = true
}

final class MinesweeperEngine: ObservableObject {
    @Published private(set) var cells: [MineCell] = []
    @Published private(set) var rows: Int = 0
    @Published private(set) var cols: Int = 0
    @Published private(set) var mineCount: Int = 0
    @Published private(set) var revealedCount: Int = 0
    @Published private(set) var flaggedCount: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var isWon: Bool = false
    @Published private(set) var firstMove: Bool = true

    private var random = SystemRandomNumberGenerator()

    init(rows: Int = 9, cols: Int = 9, mineCount: Int = 10,
         random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.rows = rows
        self.cols = cols
        self.mineCount = mineCount
        self.random = random
        newGame()
    }

    convenience init(snapshot: MinesweeperSnapshot, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.init(rows: snapshot.rows, cols: snapshot.cols, mineCount: snapshot.mineCount, random: random)
        self.cells = snapshot.cells
        self.revealedCount = snapshot.revealedCount
        self.flaggedCount = snapshot.flaggedCount
        self.isGameOver = snapshot.isGameOver
        self.isWon = snapshot.isWon
        self.firstMove = snapshot.firstMove
    }

    func newGame() {
        cells = []
        for row in 0..<rows {
            for col in 0..<cols {
                cells.append(MineCell(row: row, col: col))
            }
        }
        revealedCount = 0
        flaggedCount = 0
        isGameOver = false
        isWon = false
        firstMove = true
    }

    func reveal(row: Int, col: Int) {
        guard !isGameOver, !isWon else { return }
        guard let index = cells.firstIndex(where: { $0.row == row && $0.col == col }) else { return }
        var cell = cells[index]
        guard !cell.isRevealed, !cell.isFlagged else { return }

        if firstMove {
            placeMines(excluding: row, col: col)
            calculateAdjacentMines()
            firstMove = false
        }

        if cell.isMine {
            cell.isRevealed = true
            cells[index] = cell
            isGameOver = true
            return
        }

        revealCell(at: index)
        checkWin()
    }

    func toggleFlag(row: Int, col: Int) {
        guard !isGameOver, !isWon else { return }
        guard let index = cells.firstIndex(where: { $0.row == row && $0.col == col }) else { return }
        var cell = cells[index]
        guard !cell.isRevealed else { return }

        if cell.isFlagged {
            cell.isFlagged = false
            flaggedCount -= 1
        } else {
            cell.isFlagged = true
            flaggedCount += 1
        }
        cells[index] = cell
    }

    private func revealCell(at index: Int) {
        var cell = cells[index]
        guard !cell.isRevealed else { return }
        cell.isRevealed = true
        cells[index] = cell
        revealedCount += 1

        if cell.adjacentMines == 0 {
            let neighbors = neighborIndices(row: cell.row, col: cell.col)
            for ni in neighbors {
                if !cells[ni].isRevealed && !cells[ni].isFlagged {
                    revealCell(at: ni)
                }
            }
        }
    }

    private func placeMines(excluding row: Int, col: Int) {
        var placed = 0
        while placed < mineCount {
            let r = Int.random(in: 0..<rows)
            let c = Int.random(in: 0..<cols)
            guard r != row || c != col else { continue }
            guard let index = cells.firstIndex(where: { $0.row == r && $0.col == c }) else { continue }
            guard !cells[index].isMine else { continue }
            var cell = cells[index]
            cell.isMine = true
            cells[index] = cell
            placed += 1
        }
    }

    private func calculateAdjacentMines() {
        for i in cells.indices {
            let cell = cells[i]
            guard !cell.isMine else { continue }
            let neighbors = neighborIndices(row: cell.row, col: cell.col)
            let count = neighbors.filter { cells[$0].isMine }.count
            var updated = cell
            updated.adjacentMines = count
            cells[i] = updated
        }
    }

    private func neighborIndices(row: Int, col: Int) -> [Int] {
        var result: [Int] = []
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = row + dr, nc = col + dc
                if nr >= 0 && nr < rows && nc >= 0 && nc < cols {
                    if let index = cells.firstIndex(where: { $0.row == nr && $0.col == nc }) {
                        result.append(index)
                    }
                }
            }
        }
        return result
    }

    private func checkWin() {
        let nonMineCount = rows * cols - mineCount
        if revealedCount >= nonMineCount {
            isWon = true
        }
    }

    func snapshot() -> MinesweeperSnapshot {
        MinesweeperSnapshot(cells: cells, rows: rows, cols: cols, mineCount: mineCount,
                            revealedCount: revealedCount, flaggedCount: flaggedCount,
                            isGameOver: isGameOver, isWon: isWon, firstMove: firstMove)
    }
}
