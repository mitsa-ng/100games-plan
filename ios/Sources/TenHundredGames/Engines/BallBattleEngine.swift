import Foundation
import CoreGraphics

struct BallState: Codable, Hashable, Sendable, Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var radius: Double
    var hp: Double
    var maxHp: Double
    var isPlayer: Bool
}

struct BallBattleSnapshot: Codable, Hashable, Sendable {
    var playerBall: BallState = BallState(x: 0, y: 0, vx: 0, vy: 0, radius: 25, hp: 100, maxHp: 100, isPlayer: true)
    var aiBall: BallState = BallState(x: 0, y: 0, vx: 0, vy: 0, radius: 25, hp: 100, maxHp: 100, isPlayer: false)
    var score: Int = 0
    var timeRemaining: Double = 45
    var isGameOver: Bool = false
    var winner: Int? = nil  // 1 = 玩家, 2 = AI, 0 = 平局
}

final class BallBattleEngine: ObservableObject {
    static let width: Double = 400
    static let height: Double = 300

    @Published private(set) var playerBall: BallState = BallState(x: 0, y: 0, vx: 0, vy: 0, radius: 25, hp: 100, maxHp: 100, isPlayer: true)
    @Published private(set) var aiBall: BallState = BallState(x: 0, y: 0, vx: 0, vy: 0, radius: 25, hp: 100, maxHp: 100, isPlayer: false)
    @Published private(set) var score: Int = 0
    @Published private(set) var timeRemaining: Double = 45
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var winner: Int? = nil

    private var random = SystemRandomNumberGenerator()
    private var timer: Timer?

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.random = random
        startNewGame()
    }

    convenience init(snapshot: BallBattleSnapshot, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.init(random: random)
        self.playerBall = snapshot.playerBall
        self.aiBall = snapshot.aiBall
        self.score = snapshot.score
        self.timeRemaining = snapshot.timeRemaining
        self.isGameOver = snapshot.isGameOver
        self.winner = snapshot.winner
    }

    func startNewGame(playerHP: Double = 100, aiHP: Double = 100, playerRadius: Double = 25, aiRadius: Double = 25) {
        playerBall = BallState(x: BallBattleEngine.width * 0.25, y: BallBattleEngine.height / 2,
                               vx: 2, vy: 1, radius: playerRadius, hp: playerHP, maxHp: playerHP, isPlayer: true)
        aiBall = BallState(x: BallBattleEngine.width * 0.75, y: BallBattleEngine.height / 2,
                           vx: -2, vy: -1, radius: aiRadius, hp: aiHP, maxHp: aiHP, isPlayer: false)
        score = 0
        timeRemaining = 45
        isGameOver = false
        winner = nil
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        guard !isGameOver else { return }

        // 移動玩家球
        playerBall.x += playerBall.vx
        playerBall.y += playerBall.vy

        // 移動 AI 球（簡單追蹤）
        let dx = playerBall.x - aiBall.x
        let dy = playerBall.y - aiBall.y
        let dist = hypot(dx, dy)
        if dist > 0 {
            aiBall.vx = (dx / dist) * 1.5
            aiBall.vy = (dy / dist) * 1.5
        }
        aiBall.x += aiBall.vx
        aiBall.y += aiBall.vy

        // 邊界反彈
        bounceBall(&playerBall)
        bounceBall(&aiBall)

        // 球球碰撞
        let dx2 = playerBall.x - aiBall.x
        let dy2 = playerBall.y - aiBall.y
        let dist2 = hypot(dx2, dy2)
        let minDist = playerBall.radius + aiBall.radius
        if dist2 < minDist && dist2 > 0 {
            // 正向碰撞反彈
            let nx = dx2 / dist2
            let ny = dy2 / dist2
            playerBall.x = aiBall.x + nx * minDist
            playerBall.y = aiBall.y + ny * minDist

            // 交換速度分量
            let pvx = playerBall.vx, pvy = playerBall.vy
            playerBall.vx = aiBall.vx
            playerBall.vy = aiBall.vy
            aiBall.vx = pvx
            aiBall.vy = pvy

            // 結算傷害
            let damage = 5.0
            playerBall.hp -= damage
            aiBall.hp -= damage
        }

        // 邊界
        timeRemaining -= 0.1
        if timeRemaining <= 0 {
            endGame()
        }

        if playerBall.hp <= 0 {
            winner = 2
            endGame()
        } else if aiBall.hp <= 0 {
            winner = 1
            endGame()
        }
    }

    private func bounceBall(_ ball: inout BallState) {
        if ball.x - ball.radius < 0 {
            ball.x = ball.radius
            ball.vx = -ball.vx
        } else if ball.x + ball.radius > BallBattleEngine.width {
            ball.x = BallBattleEngine.width - ball.radius
            ball.vx = -ball.vx
        }
        if ball.y - ball.radius < 0 {
            ball.y = ball.radius
            ball.vy = -ball.vy
        } else if ball.y + ball.radius > BallBattleEngine.height {
            ball.y = BallBattleEngine.height - ball.radius
            ball.vy = -ball.vy
        }
    }

    private func endGame() {
        isGameOver = true
        timer?.invalidate()
        if winner == nil {
            if playerBall.hp > aiBall.hp { winner = 1 }
            else if aiBall.hp > playerBall.hp { winner = 2 }
            else { winner = 0 }
        }
    }

    func snapshot() -> BallBattleSnapshot {
        BallBattleSnapshot(playerBall: playerBall, aiBall: aiBall, score: score,
                           timeRemaining: timeRemaining, isGameOver: isGameOver, winner: winner)
    }
}
