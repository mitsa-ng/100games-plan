import SwiftUI
import TenHundredGames

struct SettingsView: View {
    @EnvironmentObject private var app: AppViewModel
    @State private var settings: AppSettings = AppSettings()

    var body: some View {
        NavigationStack {
            Form {
                Section("外观") {
                    Picker("主题", selection: $settings.themeMode) {
                        Text("跟随系统").tag(ThemeMode.system)
                        Text("浅色").tag(ThemeMode.light)
                        Text("深色").tag(ThemeMode.dark)
                    }
                    Toggle("动态取色", isOn: $settings.dynamicColorEnabled)
                }

                Section("反馈") {
                    Toggle("音效", isOn: $settings.soundEnabled)
                    Toggle("震动", isOn: $settings.hapticsEnabled)
                }

                Section("贪吃蛇") {
                    Picker("操作模式", selection: $settings.snakeControlMode) {
                        Text("全部").tag(SnakeControlMode.both)
                        Text("滑动").tag(SnakeControlMode.swipe)
                        Text("按键").tag(SnakeControlMode.buttons)
                    }
                    Picker("按键位置", selection: $settings.snakeControlSide) {
                        Text("左侧").tag(SnakeControlSide.left)
                        Text("右侧").tag(SnakeControlSide.right)
                    }
                }

                Section {
                    Button("保存") {
                        app.updateSettings(settings)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("设定")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            settings = app.appSettings
        }
    }
}
