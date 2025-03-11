import SwiftUI

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
