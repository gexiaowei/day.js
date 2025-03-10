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

                Text("DAY✦")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

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
            .background(Color(NSColor.windowBackgroundColor))

            // 主内容区域
            if countdownStore.events.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 70))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.secondary)

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
                            CountdownCardView(event: event)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(NSColor.windowBackgroundColor))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(event.color).opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .contentShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture {
                                    onEventSelected(event)
                                }
                                .contextMenu {
                                    Button(action: {
                                        if let index = countdownStore.events.firstIndex(where: {
                                            $0.id == event.id
                                        }) {
                                            countdownStore.deleteEvent(at: IndexSet([index]))
                                        }
                                    }) {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(NSColor.windowBackgroundColor))
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
