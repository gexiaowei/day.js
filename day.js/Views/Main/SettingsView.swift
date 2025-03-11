import SwiftUI

// 创建一个可观察对象来管理设置视图的状态
class SettingsState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedTheme: Int = 0  // 添加主题选择状态
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsState: SettingsState
    @ObservedObject private var themeManager = ThemeManager.shared

    // 通用设置
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("appTheme") private var appTheme = 0  // 添加主题存储

    // 同步设置
    @AppStorage("enableICloudSync") private var enableICloudSync = false

    var body: some View {
        VStack(spacing: 0) {
            // 内容区域 - 预加载所有视图并使用透明度动画
            ZStack {
                // 通用设置
                GeneralSettingsView(
                    launchAtLogin: $launchAtLogin,
                    enableNotifications: $enableNotifications,
                    appTheme: $appTheme
                )
                .opacity(settingsState.selectedTab == 0 ? 1 : 0)
                .zIndex(settingsState.selectedTab == 0 ? 1 : 0)

                // 同步设置
                SyncSettingsView(enableICloudSync: $enableICloudSync)
                    .opacity(settingsState.selectedTab == 1 ? 1 : 0)
                    .zIndex(settingsState.selectedTab == 1 ? 1 : 0)

                // 关于页面
                AboutSettingsView()
                    .opacity(settingsState.selectedTab == 2 ? 1 : 0)
                    .zIndex(settingsState.selectedTab == 2 ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 500, height: 500)
        .themeAware()  // 应用主题感知修饰器
        .onChange(of: appTheme) { oldValue, newValue in
            // 当主题设置变化时，应用新主题
            themeManager.updateTheme(to: AppThemeType(rawValue: newValue) ?? .system)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsState())
}
