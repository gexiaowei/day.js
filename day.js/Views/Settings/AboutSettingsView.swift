import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image("TitleBarIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)

            Text("Life More Then Days Count")
                .font(.title2.bold())

            Text("版本 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Copyright © 2025 柴白")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Link("访问官网", destination: URL(string: "https://chaibai.com.cn")!)
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AboutSettingsView()
}
