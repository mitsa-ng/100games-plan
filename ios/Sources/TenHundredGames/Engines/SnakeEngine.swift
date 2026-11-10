import Foundation

enum SnakeDirection: String, CaseIterable, Codable, Sendable {
    case up, down, left, right

    var opposite: SnakeDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    var rowDelta: Int {
        switch self {
        case .up: return -1
        case .down: return 1
        case .left, .right: return 0
        }
    }

    var colDelta: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        case .up, .down: return 0
        }
    }
}

enum SnakeDifficulty: String, CaseIterable, Codable, Sendable {
    case easy = "悠闲", normal = "标准", fast = "极速"

    var label: String { rawValue }

    var baseTickMillis: Double {
        switch self {
        case .easy: return 230
        case .normal: return 180
        case .fast: return 145
        }
    }

    var minTickMillis: Double {
        switch self {
        case .easy: return 150
        case .normal: return 115
        case .fast: return 95
        }
    }

    var foodsPerSpeedUp: Int {
        switch self {
        case .easy: return 4
        case .normal: return 3
        case .fast: return 2
        }
    }

    var speedUpStepMillis: Double {
        switch self {
        case .easy: return 12
        case .normal: return 12
        case .fast: return 10
        }
    }
}

struct SnakeCell: Codable, Hashable, Sendable, Identifiable {
    let id = UUID()
    var row: Int
    var col: Int
}

struct SnakeSnapshot: Codable, Hashable, Sendable {
    var body: [SnakeCell] = []
    var direction: SnakeDirection = .right
    var pendingDirection: SnakeDirection? = nil
    var food: SnakeCell = SnakeCell(row: 0, col: 0)
    var foodsEaten: Int = 0
    var score: Int = 0
    var gameOver: Bool = false
    var wrapAround: Bool = false
    var difficulty: SnakeDifficulty = .normal
}

final class SnakeEngine: ObservableObject {
    static let columns = 20
    static let rows = 24
    private static let scorePerFood = 10

    @Published private(set) var body: [SnakeCell] = []
    @Published private(set) var food: SnakeCell = SnakeCell(row: 0, col: 0)
    @Published private(set) var direction: SnakeDirection = .right
    @Published private(set) var pendingDirection: SnakeDirection? = nil
    @Published private(set) var foodsEaten: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var gameOver: Bool = false

    let wrapAround: Bool
    let difficulty: SnakeDifficulty

    private var internalBody: [SnakeCell]
    private var internalDirection: SnakeDirection
    private var internalPending: SnakeDirection?
    private var internalFood: SnakeCell
    private var internalFoodsEaten: Int
    private var internalScore: Int
    private var internalGameOver: Bool

    var snakeBody: [SnakeCell] { internalBody }
    var currentFood: SnakeCell { internalFood }
    var currentDirection: SnakeDirection { internalDirection }
    var currentScore: Int { internalScore }
    var eatenFoods: Int { internalFoodsEaten }
    var isGameOver: Bool { internalGameOver }
    var length: Int { internalBody.count }

    var tickIntervalMillis: Double {
        let speedSteps = internalFoodsEaten / difficulty.foodsPerSpeedUp
        return (difficulty.baseTickMillis - Double(speedSteps) * difficulty.speedUpStepMillis)
            .clamped(min: difficulty.minTickMillis)
    }

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator(),
         difficulty: SnakeDifficulty = .normal,
         wrapAround: Bool = false) {
        self.random = random
        self.difficulty = difficulty
        self.wrapAround = wrapAround

        let headRow = SnakeEngine.rows / 2
        let headCol = SnakeEngine.columns / 2 + 1
        self.internalBody = [
            SnakeCell(row: headRow, col: headCol),
            SnakeCell(row: headRow, col: headCol - 1),
            SnakeCell(row: headRow, col: headCol - 2),
        ]
        self.internalDirection = .right
        self.internalPending = nil
        self.internalFoodsEaten = 0
        self.internalScore = 0
        self.internalGameOver = false
        self.internalFood = SnakeCell(row: 0, col: 0)

        spawnInitialFood()
    }

    private var random = SystemRandomNumberGenerator()

    convenience init(snapshot: SnakeSnapshot, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.init(random: random, difficulty: snapshot.difficulty, wrapAround: snapshot.wrapAround)
        self.internalBody = snapshot.body
        self.internalDirection = snapshot.direction
        self.internalPending = snapshot.pendingDirection
        self.internalFood = snapshot.food
        self.internalFoodsEaten = max(snapshot.foodsEaten, 0)
        self.internalScore = max(snapshot.score, 0)
        self.internalGameOver = snapshot.gameOver
    }

    func turn(_ nextDirection: SnakeDirection) -> Bool {
        guard !internalGameOver else { return false }
        if nextDirection == internalDirection || nextDirection == internalDirection.opposite { return false }
        if nextDirection == internalPending { return true }
        internalPending = nextDirection
        return true
    }

    func tick() {
        guard !internalGameOver else { return }

        let queued = internalPending
        if let q = queued, q != internalDirection, q != internalDirection.opposite {
            internalDirection = q
        }
        internalPending = nil

        let head = internalBody.first!
        var nextRow = head.row + internalDirection.rowDelta
        var nextCol = head.col + internalDirection.colDelta

        if wrapAround {
            nextRow = (nextRow + SnakeEngine.rows) % SnakeEngine.rows
            nextCol = (nextCol + SnakeEngine.columns) % SnakeEngine.columns
        } else if nextRow < 0 || nextRow >= SnakeEngine.rows || nextCol < 0 || nextCol >= SnakeEngine.columns {
            internalGameOver = true
            return
        }

        let next = SnakeCell(row: nextRow, col: nextCol)
        let eating = next == internalFood
        let bodyToCheck = eating ? internalBody : Array(internalBody.dropLast())

        if bodyToCheck.contains(where: { $0.row == next.row && $0.col == next.col }) {
            internalGameOver = true
            return
        }

        internalBody.insert(next, at: 0)
        if eating {
            internalFoodsEaten += 1
            internalScore += SnakeEngine.scorePerFood
            if let newFood = spawnFood() {
                internalFood = newFood
            } else {
                internalGameOver = true
            }
        } else {
            internalBody.removeLast()
        }

        // Publish
        self.body = internalBody
        self.food = internalFood
        self.direction = internalDirection
        self.pendingDirection = internalPending
        self.foodsEaten = internalFoodsEaten
        self.score = internalScore
        self.gameOver = internalGameOver
    }

    func snapshot() -> SnakeSnapshot {
        SnakeSnapshot(body: internalBody, direction: internalDirection,
                      pendingDirection: internalPending, food: internalFood,
                      foodsEaten: internalFoodsEaten, score: internalScore,
                      gameOver: internalGameOver, wrapAround: wrapAround, difficulty: difficulty)
    }

    private func spawnInitialFood() {
        let occupied = Set(internalBody.map { "\($0.row),\($0.col)" })
        var emptyCells: [(Int, Int)] = []
        for row in 0..<SnakeEngine.rows {
            for col in 0..<SnakeEngine.columns {
                if !occupied.contains("\(row),\(col)") {
                    emptyCells.append((row, col))
                }
            }
        }
        guard !emptyCells.isEmpty else { return }
        let idx = Int.random(in: 0..<emptyCells.count)
        internalFood = SnakeCell(row: emptyCells[idx].0, col: emptyCells[idx].1)
    }

    private func spawnFood() -> SnakeCell? {
        let occupied = Set(internalBody.map { "\($0.row),\($0.col)" })
        var emptyCells: [(Int, Int)] = []
        for row in 0..<SnakeEngine.rows {
            for col in 0..<SnakeEngine.columns {
                if !occupied.contains("\(row),\(col)") {
                    emptyCells.append((row, col))
                }
            }
        }
        guard !emptyCells.isEmpty else { return nil }
        let idx = Int.random(in: 0..<emptyCells.count)
        return SnakeCell(row: emptyCells[idx].0, col: emptyCells[idx].1)
    }
}

private extension Double {
    func clamped(min: Double) -> Double { Swift.max(self, min) }
}

private extension Int {
    static func random<T: RandomNumberGenerator>(in range: Range<Int>, using generator: inout T) -> Int {
        Int.random(in: range, using: &generator)
    }
}
