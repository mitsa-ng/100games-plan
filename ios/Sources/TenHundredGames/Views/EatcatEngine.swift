import Foundation
import WebKit

@MainActor
final class EatcatEngine: ObservableObject {
    @Published private(set) var score: Int = 0
    @Published private(set) var combo: Int = 0
    @Published private(set) var rowsCleared: Int = 0
    @Published private(set) var cps: Double = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var webView: WKWebView?

    private var pollTimer: Timer?

    func createWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear

        // 載入本地 HTML 資源（需將 eatcat 網頁放入 Bundle Resources）
        if let url = Bundle.module.url(forResource: "eatcat/index", withExtension: "html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        self.webView = webView
        startPolling(webView: webView)
        return webView
    }

    private func startPolling(webView: WKWebView) {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.pollState(webView: webView)
        }
    }

    private func pollState(webView: WKWebView) {
        let js = """
        (function() {
            try {
                const state = window.eatcatState || {};
                return JSON.stringify({
                    score: state.score || 0,
                    combo: state.combo || 0,
                    rows: state.rows || 0,
                    cps: state.cps || 0,
                    gameOver: state.gameOver || false
                });
            } catch (e) {
                return JSON.stringify({score: 0, combo: 0, rows: 0, cps: 0, gameOver: false});
            }
        })();
        """
        webView.evaluateJavaScript(js) { [weak self] result, error in
            guard let self = self, let result = result as? String else { return }
            if let data = result.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                self.score = json["score"] as? Int ?? 0
                self.combo = json["combo"] as? Int ?? 0
                self.rowsCleared = json["rows"] as? Int ?? 0
                self.cps = json["cps"] as? Double ?? 0
                self.isGameOver = json["gameOver"] as? Bool ?? false
            }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
    }
}
