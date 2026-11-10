# 100Games Plan iOS (原生 Swift/SwiftUI)

這是 100Games Plan 的 iOS 原生重寫版本，使用 **Swift + SwiftUI** 開發，可編譯產出 `.ipa` 安裝包。

專案位置：`/Users/mac/Documents/100games-plan-ios/`

## 技術棧

| 層 | 技術 |
|---|------|
| 語言 | Swift 6 |
| UI | SwiftUI |
| 畫圖 | SwiftUI `Canvas` |
| 狀態管理 | `@MainActor` + `@Published` |
| 本地儲存 | `UserDefaults` + `JSONEncoder/Decoder` |
| 音效 | `AVFoundation` (`AVAudioPlayer`) |
| 震動 | `UIKit` `UIImpactFeedbackGenerator` |
| 導航 | SwiftUI `NavigationStack` |
| 本地網頁音游 | `WKWebView` (`WebKit`) |

## 已實作遊戲（13 款）

2048、俄罗斯方块、贪吃蛇、打砖块、扫雷、记忆翻牌、数独、井字棋、数字华容道、反应力挑战、谷歌小恐龙、小球对对碰、吃掉小猫猫（WKWebView）

## 本地構建（Mac + Xcode）

### 1. 開啟專案

```bash
cd /Users/mac/Documents/100games-plan-ios
```

在 Xcode 中打開此目錄（Xcode 會自動識別 Swift Package），或使用命令列：

```bash
# 編譯驗證（macOS 目標）
swift build

# 執行測試
swift test
```

### 2. 編譯 iOS 模擬器版本

```bash
xcodebuild -scheme TenHundredGames \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -configuration Debug \
  build
```

### 3. 編譯並產出 IPA（需要 Apple Developer 帳號）

產出真正的 `.ipa` 需要 **Apple Developer 帳號** 進行代碼簽名：

```bash
# 構建 Archive
xcodebuild -scheme TenHundredGames \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  -archivePath ./build/TenHundredGamesApp.xcarchive \
  archive

# 導出 IPA（需要 ExportOptions.plist 與正確的簽名憑證）
xcodebuild -exportArchive \
  -archivePath ./build/TenHundredGamesApp.xcarchive \
  -exportPath ./build/export \
  -exportOptionsPlist ./ExportOptions.plist
```

`ExportOptions.plist` 需要設定正確的 `teamID`、`method`（app-store/ad-hoc/enterprise）與簽名憑證。

## GitHub Actions 自動構建 IPA

專案包含 `.github/workflows/build-ipi.yml`，推送或發布 Release 時會自動：

1. 使用 `macos-latest` runner 編譯 Swift Package
2. 構建 iOS Archive
3. 導出 `.ipa`
4. 上傳到 GitHub Release 或 Actions Artifact

### 必要 Secrets

在 GitHub Repository 設定中添加以下 Secrets（用於代碼簽名）：

| Secret | 說明 |
|---|---|
| `APPLE_DEVELOPER_CERTIFICATE` | `.p12` 憑證檔案的 Base64 編碼 |
| `APPLE_DEVELOPER_CERTIFICATE_PASSWORD` | `.p12` 憑證密碼 |
| `APPLE_DEVELOPER_TEAM_ID` | Apple Developer Team ID |
| `APPLE_PROVISIONING_PROFILE` | `.mobileprovision` 檔案的 Base64 編碼 |

Workflow 會自動安裝憑證與描述檔，然後編譯並上傳 IPA。

## 專案結構

```
Sources/TenHundredGames/
├── App.swift               # 已移至 Xcode App 目標（請參見下方）
├── Models/                 # GameId, GameInfo, GameCatalog, PlayerStats, Achievement, AppSettings
├── Repositories/           # GameStatsRepository, SettingsRepository 協定
├── Storage/                # UserDefaults 實作
├── ViewModels/             # AppViewModel, BaseGameViewModel, 各遊戲 ViewModel
├── Views/                  # ContentView, HomeView, GameScreenView, GameScaffold, SettingsView, ...
├── Views/Games/            # 各遊戲 SwiftUI 畫面 (Canvas 繪製)
├── Engines/                # 各遊戲純 Swift 規則引擎 (13 款)
├── Feedback/               # FeedbackManager (音效/震動)
└── Navigation/             # Route 導航

Tests/TenHundredGamesTests/
└── TenHundredGamesTests.swift   # 引擎與模型單元測試
```

### App 入口點

Xcode 構建時需要一個 `@main` 的 `App.swift` 作為入口點。請在 Xcode 專案中建立：

```swift
import SwiftUI

@main
struct TenHundredGamesApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .task {
                    await appViewModel.load()
                }
                .preferredColorScheme(appViewModel.effectiveColorScheme)
        }
    }
}
```

## 測試

```bash
swift test
```

包含 2048、井字棋、貪吃蛇、玩家統計等邏輯測試。

## 限制

- 藍牙 BLE 附近聯機：未實作（iOS CoreBluetooth 需要實機與額外權限）
- 「吃掉小猫猫」網頁音游：使用 `WKWebView` 載入本地 HTML，需將網頁資源加入專案 Resources
- 診斷/掉幀監控：未實作（iOS 使用 Instruments 分析）