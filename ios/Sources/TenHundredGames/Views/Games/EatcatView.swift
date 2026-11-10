import SwiftUI

struct EatcatView: View {
    @EnvironmentObject private var app: AppViewModel
    @ObservedObject var viewModel: EatcatViewModel

    var body: some View {
        GameScaffold(title: "吃掉小猫猫", score: viewModel.score, onPause: {}) {
            VStack {
                Text("得分：\(viewModel.score)  連击：\(viewModel.engine.combo)")
                    .font(.headline)
                Text("CPS：\(String(format: "%.1f", viewModel.engine.cps))")
                    .font(.subheadline)
                #if canImport(UIKit)
                WebView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                #else
                Text("WebView 僅在 iOS 上可用")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                #endif
            }
            .padding(24)
        }
    }
}

#if canImport(UIKit)
import WebKit
import UIKit

struct WebView: UIViewRepresentable {
    let viewModel: EatcatViewModel

    func makeUIView(context: Context) -> WKWebView {
        let wv = viewModel.createWebView()
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#endif
