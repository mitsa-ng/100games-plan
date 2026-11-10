import Foundation
import CoreGraphics

struct DinoObstacle: Codable, Hashable, Sendable, Identifiable {
    let id = UUID()
    var x: Double
    var width: Double = 30
    var height: Double = 40
    var type: String = "cactus"
}

struct DinoSnapshot: Codable, Hashable, Sendable {
    var dinoY: Double = 0
    var dinoVelocityY: Double = 0
    var isJumping: Bool = false
    var obstacles: [DinoObstacle] = []
    var score: Int = 0
    var distance: Double = 0
    var speed: Double = 6
    var isGameOver: Bool = false
}

final class DinoEngine: ObservableObject {
    static let groundY: Double = 0  // 相對座標，地面位置
    static let dinoSize: Double = 40

    @Published private(set) var dinoY: Double = 0
    @Published private(set) var dinoVelocityY: Double = 0
    @Published private(set) var isJumping: Bool = false
    @Published private(set) var obstacles: [DinoObstacle] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var distance: Double = 0
    @Published private(set) var speed: Double = 6
    @Published private(set) var isGameOver: Bool = false

    private var random = SystemRandomNumberGenerator()
    private var obstacleTimer: Timer?
    private var lastObstacleX: Double = 0

    init(random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.random = random
        startNewGame()
    }

    convenience init(snapshot: DinoSnapshot, random: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.init(random: random)
        self.dinoY = snapshot.dinoY
        self.dinoVelocityY = snapshot.dinoVelocityY
        self.isJumping = snapshot.isJumping
        self.obstacles = snapshot.obstacles
        self.score = snapshot.score
        self.distance = snapshot.distance
        self.speed = snapshot.speed
        self.isGameOver = snapshot.isGameOver
    }

    func startNewGame() {
        dinoY = 0
        dinoVelocityY = 0
        isJumping = false
        obstacles = []
        score = 0
        distance = 0
        speed = 6
        isGameOver = false
        lastObstacleX = 0
        startObstacleTimer()
    }

    private func startObstacleTimer() {
        obstacleTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
            self?.spawnObstacle()
        }
    }

    private func spawnObstacle() {
        guard !isGameOver else { return }
        let x: Double = 400  // 畫面右側
        obstacles.append(DinoObstacle(x: x, type: "cactus"))
    }

    func jump() {
        guard !isGameOver else { return }
        guard !isJumping else { return }
        isJumping = true
        dinoVelocityY = -12
    }

    func tick(screenWidth: Double) {
        guard !isGameOver else { return }

        // 恐龍跳躍物理
        dinoVelocityY += 0.8  // 重力
        dinoY += dinoVelocityY

        if dinoY >= 0 {
            dinoY = 0
            dinoVelocityY = 0
            isJumping = false
        }

        // 移動障礙物
        for i in obstacles.indices {
            obstacles[i].x -= speed
        }
        obstacles.removeAll { $0.x + $0.width < 0 }

        // 碰撞檢測
        let dinoRect = CGRect(x: 50, y: dinoY, width: DinoEngine.dinoSize, height: DinoEngine.dinoSize)
        for obstacle in obstacles {
            let obsRect = CGRect(x: obstacle.x, y: DinoEngine.groundY - obstacle.height,
                                 width: obstacle.width, height: obstacle.height)
            if dinoRect.intersects(obsRect) {
                isGameOver = true
                obstacleTimer?.invalidate()
                return
            }
        }

        // 計分
        distance += speed * 0.016  // 假設 60fps
        score = Int(distance / 10)

        // 漸進加速
        speed = 6 + distance / 1000
    }

    func snapshot() -> DinoSnapshot {
        DinoSnapshot(dinoY: dinoY, dinoVelocityY: dinoVelocityY, isJumping: isJumping,
                     obstacles: obstacles, score: score, distance: distance,
                     speed: speed, isGameOver: isGameOver)
    }
}
