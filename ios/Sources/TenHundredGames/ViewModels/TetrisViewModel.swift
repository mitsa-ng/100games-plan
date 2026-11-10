import SwiftUI

enum TetrominoType: Int, CaseIterable, Codable, Sendable {
    case I, J, L, O, S, T, Z

    var color: Color {
        switch self {
        case .I: return .cyan
        case .J: return .blue
        case .L: return .orange
        case .O: return .yellow
        case .S: return .green
        case .T: return .purple
        case .Z: return .red
        }
    }
}

struct Tetromino: Sendable {
    let type: TetrominoType
    var cells: [(Int, Int)]  // (row, col) 相對於基準點
}

struct TetrisSnapshot: Sendable {
    var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 10), count: 20)
    var current: Tetromino? = nil
    var currentPos: (Int, Int) = (0, 0)
    var score: Int = 0
    var level: Int = 1
    var lines: Int = 0
    var isGameOver: Bool = false
}

final class TetrisEngine: ObservableObject {
    static let rows = 20
    static let cols = 10

    @Published private(set) var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: cols), count: rows)
    @Published private(set) var current: Tetromino?
    @Published private(set) var currentPos: (Int, Int) = (0, 0)
    @Published private(set) var score: Int = 0
    @Published private(set) var level: Int = 1
    @Published private(set) var lines: Int = 0
    @Published private(set) var isGameOver: Bool = false

    private var random = SystemRandomNumberGenerator()

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.random = random
        spawnPiece()
    }

    func spawnPiece() {
        let types = TetrominoType.allCases
        let type = types[Int.random(in: 0..<types.count)]
        var cells: [(Int, Int)] = []
        switch type {
        case .I: cells = [(0,0),(0,1),(0,2),(0,3)]
        case .O: cells = [(0,0),(0,1),(1,0),(1,1)]
        case .T: cells = [(0,0),(0,1),(0,2),(1,1)]
        case .S: cells = [(0,1),(0,2),(1,0),(1,1)]
        case .Z: cells = [(0,0),(0,1),(1,1),(1,2)]
        case .J: cells = [(0,0),(1,0),(2,0),(2,1)]
        case .L: cells = [(0,1),(1,1),(2,0),(2,1)]
        }
        current = Tetromino(type: type, cells: cells)
        currentPos = (0, 3)
        if !isValid(position: currentPos, piece: current!) {
            isGameOver = true
        }
    }

    private func isValid(position: (Int, Int), piece: Tetromino) -> Bool {
        for (r, c) in piece.cells {
            let nr = position.0 + r
            let nc = position.1 + c
            if nr < 0 || nr >= TetrisEngine.rows || nc < 0 || nc >= TetrisEngine.cols { return false }
            if grid[nr][nc] != 0 { return false }
        }
        return true
    }

    func moveLeft() {
        guard !isGameOver, let piece = current else { return }
        let newPos = (currentPos.0, currentPos.1 - 1)
        if isValid(position: newPos, piece: piece) { currentPos = newPos }
    }

    func moveRight() {
        guard !isGameOver, let piece = current else { return }
        let newPos = (currentPos.0, currentPos.1 + 1)
        if isValid(position: newPos, piece: piece) { currentPos = newPos }
    }

    func moveDown() -> Bool {
        guard !isGameOver, let piece = current else { return false }
        let newPos = (currentPos.0 + 1, currentPos.1)
        if isValid(position: newPos, piece: piece) {
            currentPos = newPos
            return true
        } else {
            lockPiece()
            return false
        }
    }

    private func lockPiece() {
        guard let piece = current else { return }
        for (r, c) in piece.cells {
            let nr = currentPos.0 + r
            let nc = currentPos.1 + c
            if nr >= 0 && nr < TetrisEngine.rows && nc >= 0 && nc < TetrisEngine.cols {
                grid[nr][nc] = piece.type.rawValue + 1
            }
        }
        clearLines()
        spawnPiece()
    }

    private func clearLines() {
        var newGrid: [[Int]] = []
        var cleared = 0
        for row in 0..<TetrisEngine.rows {
            if grid[row].allSatisfy({ $0 != 0 }) {
                cleared += 1
            } else {
                newGrid.append(grid[row])
            }
        }
        while newGrid.count < TetrisEngine.rows {
            newGrid.insert(Array(repeating: 0, count: TetrisEngine.cols), at: 0)
        }
        grid = newGrid
        if cleared > 0 {
            lines += cleared
            score += cleared * 100 * level
            level = lines / 10 + 1
        }
    }

    func rotate() {
        guard !isGameOver, let piece = current else { return }
        // 簡化旋轉：順時針 90 度
        let rotatedCells = piece.cells.map { (r, c) in (c, -r) }
        // 歸一化
        let minR = rotatedCells.map { $0.0 }.min() ?? 0
        let minC = rotatedCells.map { $0.1 }.min() ?? 0
        let normalized = rotatedCells.map { ($0.0 - minR, $0.1 - minC) }
        let rotated = Tetromino(type: piece.type, cells: normalized)
        if isValid(position: currentPos, piece: rotated) {
            current = rotated
        }
    }

    func hardDrop() {
        guard !isGameOver else { return }
        while moveDown() {}
    }
}

@MainActor
final class TetrisViewModel: BaseGameViewModel {
    @Published private(set) var engine: TetrisEngine = TetrisEngine()
    private var gameTimer: Timer?

    override var gameId: GameId { .tetris }

    override func startNewGame() {
        engine = TetrisEngine()
        score = 0
        isGameOver = false
        showingGameOver = false
        startTimer()
    }

    private func startTimer() {
        gameTimer?.invalidate()
        let interval = 0.8
        gameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        let locked = engine.moveDown()
        score = engine.score
        isGameOver = engine.isGameOver
        if isGameOver {
            gameTimer?.invalidate()
            endGame(finalScore: score)
        }
    }

    func moveLeft() { engine.moveLeft() }
    func moveRight() { engine.moveRight() }
    func moveDown() { _ = engine.moveDown() }
    func rotate() { engine.rotate() }
    func hardDrop() { engine.hardDrop() }
}
