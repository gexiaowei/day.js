import SwiftUI

struct EventDetailContainerView: View {
    @ObservedObject var countdownStore: CountdownStore
    let event: CountdownEvent
    let onBack: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题和返回按钮
            HStack(alignment: .center) {
                Button {
                    onBack()
                } label: {
                    SFSymbolIcon(symbol: .chevronLeft, size: 18, color: .accentColor)
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

                HStack(alignment: .bottom, spacing: 8) {
                    Button {
                        onEdit()
                    } label: {
                        Text("编辑")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                    Button {
                        onEdit()
                    } label: {
                        SFSymbolIcon(symbol: .squareAndArrowUp, size: 20, color: .accentColor)
                            .themeAware()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))

            EventDetailView(countdownStore: countdownStore, event: event)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
