import SwiftUI

// SF Symbols 图标名称枚举
enum SFSymbol: String {
    case calendar = "calendar"
    case plus = "plus"
    case pencil = "pencil"
    case chevronLeft = "chevron.left"
    case trash = "trash"
    case check = "checkmark"
    case gear = "gear"
    case info = "info.circle"
    case repeatIcon = "arrow.clockwise"
    case note = "note.text"
    case circle = "circle"
    case image = "photo"
    case color = "paintpalette"
    case date = "calendar.badge.clock"
    case time = "clock"
    case tag = "tag"
    case sync = "arrow.triangle.2.circlepath"
    case about = "info.circle.fill"
    case xmark = "xmark.circle.fill"
    case checkCircle = "checkmark.circle.fill"
    case trashCircle = "trash.circle.fill"
    case plusCircle = "plus.circle.fill"
    case pencilCircle = "pencil.circle.fill"
}

// SF Symbols 图标视图
struct SFSymbolIcon: View {
    let symbol: SFSymbol
    var size: CGFloat = 24
    var color: Color = .primary
    var useThemeAware: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Image(systemName: symbol.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(useThemeAware ? (colorScheme == .dark ? .white : .black) : color)
    }
    
    // 主题感知修饰器
    func themeAware() -> SFSymbolIcon {
        var icon = self
        icon.useThemeAware = true
        return icon
    }
}

// 预览
#Preview {
    VStack(spacing: 20) {
        Text("普通图标")
            .font(.headline)
        
        HStack(spacing: 20) {
            SFSymbolIcon(symbol: .calendar, color: .blue)
            SFSymbolIcon(symbol: .plus, color: .green)
            SFSymbolIcon(symbol: .pencil, color: .orange)
            SFSymbolIcon(symbol: .chevronLeft, color: .red)
        }
        
        Text("主题感知图标")
            .font(.headline)
            .padding(.top)
        
        HStack(spacing: 20) {
            SFSymbolIcon(symbol: .calendar).themeAware()
            SFSymbolIcon(symbol: .plus).themeAware()
            SFSymbolIcon(symbol: .pencil).themeAware()
            SFSymbolIcon(symbol: .chevronLeft).themeAware()
        }
        
        HStack(spacing: 20) {
            SFSymbolIcon(symbol: .trash).themeAware()
            SFSymbolIcon(symbol: .check).themeAware()
            SFSymbolIcon(symbol: .gear).themeAware()
            SFSymbolIcon(symbol: .info).themeAware()
        }
        
        HStack(spacing: 20) {
            SFSymbolIcon(symbol: .repeatIcon).themeAware()
            SFSymbolIcon(symbol: .note).themeAware()
            SFSymbolIcon(symbol: .circle).themeAware()
        }
    }
    .padding()
    .preferredColorScheme(.light)
    
    VStack(spacing: 20) {
        Text("普通图标")
            .font(.headline)
        
        HStack(spacing: 20) {
            SFSymbolIcon(symbol: .calendar, color: .blue)
            SFSymbolIcon(symbol: .plus, color: .green)
            SFSymbolIcon(symbol: .pencil, color: .orange)
            SFSymbolIcon(symbol: .chevronLeft, color: .red)
        }
        
        Text("主题感知图标")
            .font(.headline)
            .padding(.top)
        
        HStack(spacing: 20) {
            SFSymbolIcon(symbol: .calendar).themeAware()
            SFSymbolIcon(symbol: .plus).themeAware()
            SFSymbolIcon(symbol: .pencil).themeAware()
            SFSymbolIcon(symbol: .chevronLeft).themeAware()
        }
    }
    .padding()
    .preferredColorScheme(.dark)
} 