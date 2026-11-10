import Foundation
import CoreGraphics

struct BreakoutBall: Codable, Hashable, Sendable {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var radius: Double = 6
}

struct BreakoutPaddle: Codable, Hashable, Sendable {
    var x: Double
    var y: Double
    var width: Double = 80
    var height: Double = 12
}

struct BreakoutBrick: Codable, Hashable, Sendable, Identifiable {
    let id: Int
    var row: Int
    var col: Int
    var value: Int
    var destroyed: Bool = false
}

struct BreakoutSnapshot: Codable, Hashable, Sendable {
    var ball: BreakoutBall = BreakoutBall(x: 0, y: 0, vx: 0, vy: 0)
    var paddle: BreakoutPaddle = BreakoutPaddle(x: 0, y: 0)
    var bricks: [BreakoutBrick] = []
    var score: Int = 0
    var lives: Int = 3
    var isGameOver: Bool = false
    var isWon: Bool = false
}

final class BreakoutEngine: ObservableObject {
    static let cols = 8
    static let rows = 5
    static let paddleY: Double = 0  // 相對於畫面底部

    @Published private(set) var ball: BreakoutBall = BreakoutBall(x: 0, y: 0, vx: 0, vy: 0)
    @Published private(set) var paddle: BreakoutPaddle = BreakoutPaddle(x: 0, y: 0)
    @Published private(set) var bricks: [BreakoutBrick] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var lives: Int = 3
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var isWon: Bool = false

    private var random = SystemRandomNumberGenerator()

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.random = random
        startNewGame()
    }

    convenience init(snapshot: BreakoutSnapshot, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.init(random: random)
        self.ball = snapshot.ball
        self.paddle = snapshot.paddle
        self.bricks = snapshot.bricks
        self.score = snapshot.score
        self.lives = snapshot.lives
        self.isGameOver = snapshot.isGameOver
        self.isWon = snapshot.isWon
    }

    func startNewGame() {
        lives = 3
        score = 0
        isGameOver = false
        isWon = false
        resetBall()
        generateBricks()
    }

    func resetBall() {
        ball = BreakoutBall(x: 0, y: -BreakoutEngine.paddleY - 30, vx: Double.random(in: 2...4) * (Bool.random() ? 1 : -1), vy: -5)
    }

    func generateBricks() {
        bricks = []
        var id = 0
        for row in 0..<BreakoutEngine.rows {
            for col in 0..<BreakoutEngine.cols {
                let value = (row + 1) * 10
                bricks.append(BreakoutBrick(id: id, row: row, col: col, value: value, destroyed: false))
                id += 1
            }
        }
    }

    func updatePaddle(x: Double, screenWidth: Double) {
        let halfW = paddle.width / 2
        var newX = x - halfW
        newX = max(0, min(screenWidth - paddle.width, newX))
        paddle.x = newX
    }

    func tick(screenWidth: Double, screenHeight: Double) {
        guard !isGameOver, !isWon else { return }

        ball.x += ball.vx
        ball.y += ball.vy

        // 左右牆壁
        if ball.x - ball.radius < 0 {
            ball.x = ball.radius
            ball.vx = -ball.vx
        } else if ball.x + ball.radius > screenWidth {
            ball.x = screenWidth - ball.radius
            ball.vx = -ball.vx
        }

        // 上牆壁
        if ball.y - ball.radius < 0 {
            ball.y = ball.radius
            ball.vy = -ball.vy
        }

        // 撞到挡板
        let paddleRect = CGRect(x: paddle.x, y: paddle.y, width: paddle.width, height: paddle.height)
        let ballRect = CGRect(x: ball.x - ball.radius, y: ball.y - ball.radius,
                              width: ball.radius * 2, height: ball.radius * 2)
        if ballRect.intersects(paddleRect) && ball.vy > 0 {
            ball.vy = -ball.vy
            // 根據擊中位置調整水平速度
            let hitPos = (ball.x - (paddle.x + paddle.width / 2)) / (paddle.width / 2)
            ball.vx = hitPos * 5
        }

        // 撞到磚塊
        for i in bricks.indices where !bricks[i].destroyed {
            let brickSize: Double = 40
            let brickX = Double(bricks[i].col) * (brickSize + 8) + 40
            let brickY = Double(bricks[i].row) * (brickSize + 8) + 60
            let brickRect = CGRect(x: brickX, y: brickY, width: brickSize, height: brickSize)
            if ballRect.intersects(brickRect) {
                bricks[i].destroyed = true
                score += bricks[i].value
                ball.vy = -ball.vy
                break
            }
        }

        // 檢查勝負
        if bricks.allSatisfy({ $0.destroyed }) {
            isWon = true
        }

        // 掉下去
        if ball.y - ball.radius > screenHeight {
            lives -= 1
            if lives <= 0 {
                isGameOver = true
            } else {
                resetBall()
            }
        }
    }

    func snapshot() -> BreakoutSnapshot {
        BreakoutSnapshot(ball: ball, paddle: paddle, bricks: bricks,
                         score: score, lives: lives,
                         isGameOver: isGameOver, isWon: isWon)
    }
}
