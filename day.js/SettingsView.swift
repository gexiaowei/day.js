import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    // 通用设置
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("enableNotifications") private var enableNotifications = true
    
    // 同步设置
    @AppStorage("enableICloudSync") private var enableICloudSync = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("设置")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            
            // 选项卡栏
            HStack(spacing: 0) {
                TabButton(title: "通用", systemImage: "gear", isSelected: selectedTab == 0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 0
                    }
                }
                
                TabButton(title: "同步", systemImage: "arrow.triangle.2.circlepath.circle", isSelected: selectedTab == 1) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 1
                    }
                }
                
                TabButton(title: "关于", systemImage: "info.circle", isSelected: selectedTab == 2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 2
                    }
                }
            }
            .padding(.top, 8)
            
            // 内容区域 - 预加载所有视图并使用透明度动画
            ZStack {
                // 通用设置
                GeneralSettingsView(launchAtLogin: $launchAtLogin, enableNotifications: $enableNotifications)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .zIndex(selectedTab == 0 ? 1 : 0)
                
                // 同步设置
                SyncSettingsView(enableICloudSync: $enableICloudSync)
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .zIndex(selectedTab == 1 ? 1 : 0)
                
                // 关于页面
                AboutSettingsView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .zIndex(selectedTab == 2 ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 500, height: 500)
    }
}

// 通用设置视图
struct GeneralSettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var enableNotifications: Bool
    
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
                
                Picker("应用主题", selection: .constant(0)) {
                    Text("跟随系统").tag(0)
                    Text("浅色").tag(1)
                    Text("深色").tag(2)
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
            }
            .padding()
        }
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
                
                Divider()
                    .padding(.vertical, 8)
                
                SettingsSectionHeader(title: "数据管理")
                
                Button(action: {
                    // 导出数据功能（暂未实现）
                }) {
                    Label("导出数据", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Button(action: {
                    // 导入数据功能（暂未实现）
                }) {
                    Label("导入数据", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .padding()
        }
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
    }
}

// 选项卡按钮
struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 12))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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