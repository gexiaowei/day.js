import SwiftUI

struct GeneralSettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var enableNotifications: Bool
    @Binding var appTheme: Int
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SettingsSectionHeader(title: "应用行为")

                Toggle("开机启动", isOn: $launchAtLogin)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.horizontal)

                Toggle("启用提醒通知", isOn: $enableNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)

                SettingsSectionHeader(title: "外观")

                VStack(alignment: .leading, spacing: 10) {
                    Text("应用主题")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        RadioButton(id: 0, label: "跟随系统", isSelected: appTheme == 0) {
                            appTheme = $0
                            themeManager.updateTheme(to: .system)
                        }
                        .padding(.horizontal)

                        RadioButton(id: 1, label: "浅色", isSelected: appTheme == 1) {
                            appTheme = $0
                            themeManager.updateTheme(to: .light)
                        }
                        .padding(.horizontal)

                        RadioButton(id: 2, label: "深色", isSelected: appTheme == 2) {
                            appTheme = $0
                            themeManager.updateTheme(to: .dark)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    GeneralSettingsView(
        launchAtLogin: .constant(false),
        enableNotifications: .constant(true),
        appTheme: .constant(0)
    )
}
