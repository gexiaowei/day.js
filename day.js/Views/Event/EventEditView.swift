import SwiftUI

struct EventEditView: View {
    @ObservedObject var countdownStore: CountdownStore
    let event: CountdownEvent
    let onBack: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题和返回按钮
            HStack {
                Button {
                    onBack()
                } label: {
                    SFSymbolIcon(symbol: .chevronLeft, size: 16, color: .accentColor)
                        .themeAware()
                }
                .buttonStyle(.plain)

                Spacer()

                Text(event.title)
                    .font(.system(size: 20, weight: .bold))
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    onSave()
                } label: {
                    Text("保存")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))

            EditEventView(countdownStore: countdownStore, event: event)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


