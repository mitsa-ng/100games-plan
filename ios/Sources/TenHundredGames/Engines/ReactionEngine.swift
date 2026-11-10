import Foundation

struct ReactionSnapshot: Codable, Hashable, Sendable {
    var round: Int = 1
    var maxRounds: Int = 5
    var reactionTimes: [Int] = []  // 毫秒
    var isWaiting: Bool = false
    var isShowingColor: Bool = false
    var startTime: Date? = nil
    var isGameOver: Bool = false
    var falseStart: Bool = false
}

@MainActor
final class ReactionEngine: ObservableObject {
    @Published private(set) var round: Int = 1
    @Published private(set) var maxRounds: Int = 5
    @Published private(set) var reactionTimes: [Int] = []
    @Published private(set) var isWaiting: Bool = false
    @Published private(set) var isShowingColor: Bool = false
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var falseStart: Bool = false

    private var startTime: Date? = nil

    init() {}

    convenience init(snapshot: ReactionSnapshot) {
        self.init()
        self.round = snapshot.round
        self.maxRounds = snapshot.maxRounds
        self.reactionTimes = snapshot.reactionTimes
        self.isWaiting = snapshot.isWaiting
        self.isShowingColor = snapshot.isShowingColor
        self.isGameOver = snapshot.isGameOver
        self.falseStart = snapshot.falseStart
        self.startTime = snapshot.startTime
    }

    func startNewGame() {
        round = 1
        reactionTimes = []
        isGameOver = false
        falseStart = false
        isWaiting = false
        isShowingColor = false
        startTime = nil
        startRound()
    }

    func startRound() {
        isWaiting = true
        isShowingColor = false
        falseStart = false
        startTime = nil

        let delay = Double.random(in: 1.5...3.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            Task { @MainActor in
                self.showColor()
            }
        }
    }

    func showColor() {
        isWaiting = false
        isShowingColor = true
        startTime = Date()
    }

    func onTap() -> Int? {
        guard isShowingColor, let start = startTime else {
            falseStart = true
            return nil
        }
        let elapsed = Int(Date().timeIntervalSince(start) * 1000)
        reactionTimes.append(elapsed)
        isShowingColor = false
        round += 1

        if round > maxRounds {
            isGameOver = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                Task { @MainActor in
                    self.startRound()
                }
            }
        }
        return elapsed
    }

    func onFalseStart() {
        guard isWaiting else { return }
        falseStart = true
        isWaiting = false
        round += 1
        if round > maxRounds {
            isGameOver = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                Task { @MainActor in
                    self.startRound()
                }
            }
        }
    }

    var averageReactionTime: Int {
        guard !reactionTimes.isEmpty else { return 0 }
        return reactionTimes.reduce(0, +) / reactionTimes.count
    }

    var bestReactionTime: Int {
        reactionTimes.min() ?? 0
    }

    func snapshot() -> ReactionSnapshot {
        ReactionSnapshot(round: round, maxRounds: maxRounds, reactionTimes: reactionTimes,
                         isWaiting: isWaiting, isShowingColor: isShowingColor,
                         startTime: startTime, isGameOver: isGameOver, falseStart: falseStart)
    }
}
