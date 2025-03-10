import SwiftUI

// 创建一个可观察对象来管理设置视图的状态
class SettingsState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedTheme: Int = 0 // 添加主题选择状态
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsState: SettingsState
    @ObservedObject private var themeManager = ThemeManager.shared
    
    // 通用设置
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("appTheme") private var appTheme = 0 // 添加主题存储
    
    // 同步设置
    @AppStorage("enableICloudSync") private var enableICloudSync = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 内容区域 - 预加载所有视图并使用透明度动画
            ZStack {
                // 通用设置
                GeneralSettingsView(launchAtLogin: $launchAtLogin, enableNotifications: $enableNotifications, appTheme: $appTheme)
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
        .themeAware() // 应用主题感知修饰器
        .onChange(of: appTheme) { oldValue, newValue in
            // 当主题设置变化时，应用新主题
            themeManager.updateTheme(to: AppThemeType(rawValue: newValue) ?? .system)
        }
    }
}

// 为View添加圆角扩展
extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// 自定义圆角形状
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = corners.contains(.topLeft)
        let topRight = corners.contains(.topRight)
        let bottomLeft = corners.contains(.bottomLeft)
        let bottomRight = corners.contains(.bottomRight)
        
        let width = rect.width
        let height = rect.height
        
        // 顶部左侧
        if topLeft {
            path.move(to: CGPoint(x: 0, y: radius))
            path.addArc(center: CGPoint(x: radius, y: radius),
                        radius: radius,
                        startAngle: .degrees(180),
                        endAngle: .degrees(270),
                        clockwise: false)
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
        }
        
        // 顶部右侧
        if topRight {
            path.addLine(to: CGPoint(x: width - radius, y: 0))
            path.addArc(center: CGPoint(x: width - radius, y: radius),
                        radius: radius,
                        startAngle: .degrees(270),
                        endAngle: .degrees(0),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        
        // 底部右侧
        if bottomRight {
            path.addLine(to: CGPoint(x: width, y: height - radius))
            path.addArc(center: CGPoint(x: width - radius, y: height - radius),
                        radius: radius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: width, y: height))
        }
        
        // 底部左侧
        if bottomLeft {
            path.addLine(to: CGPoint(x: radius, y: height))
            path.addArc(center: CGPoint(x: radius, y: height - radius),
                        radius: radius,
                        startAngle: .degrees(90),
                        endAngle: .degrees(180),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        
        path.closeSubpath()
        return path
    }
}

// 定义矩形角落
struct RectCorner: OptionSet {
    let rawValue: Int
    
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

// 通用设置视图
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
        .themeAware() // 应用主题感知修饰器
    }
}

// 同步设置视图
struct SyncSettingsView: View {
    @Binding var enableICloudSync: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SettingsSectionHeader(title: "iCloud 同步")
                
                Toggle("启用 iCloud 同步", isOn: $enableICloudSync)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.horizontal)
                
                if enableICloudSync {
                    Text("您的倒计时事件将在所有使用相同 Apple ID 的设备上同步。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    Text("启用此选项可在所有使用相同 Apple ID 的设备上同步您的倒计时事件。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .themeAware() // 应用主题感知修饰器
    }
}

// 关于设置视图
struct AboutSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Text("倒计时")
                    .font(.title2.bold())
                
                Text("版本 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("功能特点")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    FeatureRow(icon: "calendar", text: "支持公历和农历日期")
                    FeatureRow(icon: "repeat", text: "支持日/月/年重复周期")
                    FeatureRow(icon: "photo", text: "支持自定义事件图片")
                    FeatureRow(icon: "paintpalette", text: "多种颜色主题选择")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("联系我们")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Button(action: {
                        // 打开邮件客户端（暂未实现）
                    }) {
                        Label("发送反馈", systemImage: "envelope")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 5)
                    
                    Button(action: {
                        // 打开网站（暂未实现）
                    }) {
                        Label("访问官网", systemImage: "globe")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .themeAware() // 应用主题感知修饰器
    }
}

// 功能行
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .foregroundColor(.primary)
        }
    }
}

// 设置区域标题
struct SettingsSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

// 添加 RadioButton 组件
struct RadioButton: View {
    let id: Int
    let label: String
    let isSelected: Bool
    let callback: ((Int) -> Void)?
    
    var body: some View {
        Button(action: {
            if let callback = self.callback {
                callback(self.id)
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                
                Text(label)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
} 