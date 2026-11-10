import SwiftUI

#if canImport(UIKit)
import WebKit
#endif

@MainActor
final class EatcatViewModel: BaseGameViewModel {
#if canImport(UIKit)
    @Published private(set) var engine: EatcatEngine = EatcatEngine()
#else
    @Published private(set) var engine: EatcatEnginePlaceholder = EatcatEnginePlaceholder()
#endif

    override var gameId: GameId { .eatcat }

    override func startNewGame() {
#if canImport(UIKit)
        engine = EatcatEngine()
#else
        engine = EatcatEnginePlaceholder()
#endif
        score = 0
        isGameOver = false
        showingGameOver = false
    }

#if canImport(UIKit)
    func createWebView() -> WKWebView {
        engine.createWebView()
    }
#else
    func createWebView() -> Never {
        fatalError("WebView 仅在 iOS 上可用")
    }
#endif
}

#if !canImport(UIKit)
final class EatcatEnginePlaceholder: ObservableObject {
    @Published var score: Int = 0
    @Published var combo: Int = 0
    @Published var cps: Double = 0
    @Published var isGameOver: Bool = false
}
#endif
