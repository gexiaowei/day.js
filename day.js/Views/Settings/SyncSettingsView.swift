import SwiftUI

struct SyncSettingsView: View {
    @Binding var enableICloudSync: Bool

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {
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
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SyncSettingsView(enableICloudSync: .constant(false))
}
