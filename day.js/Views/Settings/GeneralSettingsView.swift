import SwiftUI

struct GeneralSettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var enableNotifications: Bool
    @Binding var appTheme: Int
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {

            Toggle("开机启动", isOn: $launchAtLogin)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.horizontal)

            Toggle("启用提醒通知", isOn: $enableNotifications)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.horizontal)

            HStack(alignment: .center, spacing: 20) {
                Text("应用主题")
                    .font(.body)
                    .foregroundColor(.primary)

                HStack(alignment: .center, spacing: 0) {
                    RadioButton(id: 1, label: "浅色", isSelected: appTheme == 1) {
                        appTheme = $0
                        themeManager.updateTheme(to: .light)
                    }.frame(width: 70)

                    RadioButton(id: 2, label: "深色", isSelected: appTheme == 2) {
                        appTheme = $0
                        themeManager.updateTheme(to: .dark)
                    }
                    .frame(width: 70)
                    RadioButton(id: 0, label: "跟随系统", isSelected: appTheme == 0) {
                        appTheme = $0
                        themeManager.updateTheme(to: .system)
                    }.frame(width: 100)

                }
            }.padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GeneralSettingsView(
        launchAtLogin: .constant(false),
        enableNotifications: .constant(true),
        appTheme: .constant(0)
    )
}
