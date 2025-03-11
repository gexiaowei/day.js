import SwiftUI

struct EventListView: View {
    @ObservedObject var countdownStore: CountdownStore
    let onAddEventTapped: () -> Void
    let onEventSelected: (CountdownEvent) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题和添加按钮
            HStack {
                Spacer()

                Image("TitleBarIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 24)

                Spacer()

                Button {
                    onAddEventTapped()
                } label: {
                    SFSymbolIcon(symbol: .plus, size: 18, color: .accentColor)
                        .themeAware()
                }
                .id("addButton")
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)

            // 主内容区域
            if countdownStore.events.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image("MenubarIconLight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)

                    Text("没有事件")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("点击右上角的+按钮添加新的事件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(countdownStore.events) { event in
                            CountdownCardView(event: event, countdownStore: countdownStore)
                                .onTapGesture {
                                    onEventSelected(event)
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EventListView(
        countdownStore: CountdownStore(),
        onAddEventTapped: {},
        onEventSelected: { _ in }
    )
}
