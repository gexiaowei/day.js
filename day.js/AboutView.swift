import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            
            Text("倒计时")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text("版本 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("功能特点：")
                    .font(.headline)
                    .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 5) {
                    FeatureRow(icon: "calendar", text: "支持公历和农历日期")
                    FeatureRow(icon: "repeat", text: "支持日/月/年重复周期")
                    FeatureRow(icon: "photo", text: "支持自定义事件图片")
                    FeatureRow(icon: "paintpalette", text: "多种颜色主题选择")
                }
                .padding(.leading, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            Button("关闭") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .frame(width: 350, height: 450)
        .padding()
    }
}

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