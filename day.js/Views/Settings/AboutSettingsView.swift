import SwiftUI

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

                    Text("• 支持公历和农历日期")
                    Text("• 支持每月和每年重复")
                    Text("• 支持自定义事件颜色")
                    Text("• 支持添加事件图片")
                    Text("• 支持 iCloud 同步")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

                Link("访问官网", destination: URL(string: "https://example.com")!)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

#Preview {
    AboutSettingsView()
}
