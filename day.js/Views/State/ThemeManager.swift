import SwiftUI
import AppKit

// 主题类型枚举
enum AppThemeType: Int {
    case system = 0
    case light = 1
    case dark = 2
}

// 主题管理器
class ThemeManager: ObservableObject {
    // 单例模式
    static let shared = ThemeManager()
    
    // 当前主题设置
    @AppStorage("appTheme") private var appTheme: Int = 0
    
    // 当前系统外观
    @Published var currentAppearance: NSAppearance.Name = .aqua
    
    // 系统外观监听器
    private var appearanceObserver: NSKeyValueObservation?
    
    private init() {
        // 初始化时设置当前系统外观
        if let appearance = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
            currentAppearance = appearance
        }
        
        // 监听系统外观变化
        appearanceObserver = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
            guard let self = self else { return }
            
            if let appearance = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
                self.currentAppearance = appearance
                self.applyTheme()
            }
        }
        
        // 初始应用主题
        applyTheme()
    }
    
    // 应用主题
    func applyTheme() {
        let themeType = AppThemeType(rawValue: appTheme) ?? .system
        
        switch themeType {
        case .system:
            // 跟随系统设置
            break
        case .light:
            // 强制使用浅色模式
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            // 强制使用深色模式
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
    
    // 更新主题设置
    func updateTheme(to themeType: AppThemeType) {
        appTheme = themeType.rawValue
        applyTheme()
    }
    
    // 获取当前主题类型
    var currentThemeType: AppThemeType {
        return AppThemeType(rawValue: appTheme) ?? .system
    }
    
    // 判断当前是否为深色模式
    var isDarkMode: Bool {
        if currentThemeType == .dark {
            return true
        } else if currentThemeType == .light {
            return false
        } else {
            // 跟随系统
            return currentAppearance == .darkAqua
        }
    }
}

// 为视图提供主题环境的修饰器
struct ThemeAwareModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
            .onChange(of: themeManager.currentAppearance) { oldValue, newValue in
                // 当系统外观变化时，如果设置为跟随系统，则需要刷新视图
                if themeManager.currentThemeType == .system {
                    // 触发视图刷新
                }
            }
    }
}

// 扩展 View 以便于应用主题
extension View {
    func themeAware() -> some View {
        self.modifier(ThemeAwareModifier())
    }
} 