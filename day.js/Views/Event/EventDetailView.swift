import SwiftUI

struct EventDetailView: View {
    @ObservedObject var countdownStore: CountdownStore
    let eventId: UUID  // 存储事件ID而不是事件本身
    let onBack: () -> Void
    let onEdit: () -> Void

    // 计算属性来获取最新的事件数据
    private var event: CountdownEvent {
        countdownStore.events.first { $0.id == eventId }
            ?? CountdownEvent(
                title: "未找到事件",
                targetDate: Date(),
                calendarType: .gregorian,
                repeatCycle: .none,
                color: "SORA"
            )
    }

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
            

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 16) {
                    // 如果有图片，显示图片
                    ZStack {
                        Circle()
                            .fill(Color(event.color))  // 使用 color 参数并设置透明度
                            .frame(width: 210, height: 210)  // 圆形尺寸
                            .opacity(0.38)
                        Circle()
                            .fill(Color(event.color))  // 使用 color 参数并设置透明度
                            .frame(width: 190, height: 190)  // 圆形尺寸
                            .opacity(0.62)
                        if let imageData = event.imageData, let nsImage = NSImage(data: imageData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(Circle())
                                .padding(.horizontal)
                        } else {
                            SFSymbolIcon(symbol: .image, size: 100, color: .secondary)
                                .frame(width: 170, height: 170)
                                .background(.white)
                                .clipShape(Circle())
                                .padding(.horizontal)
                        }
                    }

                    // 事件信息
                    VStack(alignment: .center, spacing: 20) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(event.repeatCycle.rawValue)
                                .font(.body)
                            Text("·")
                                .font(.body)
                            Text(event.calendarType.rawValue)
                                .font(.body)
                            Text("·")
                                .font(.body)

                            if event.calendarType == .lunar {
                                Text(
                                    DateFormatUtils.formattedLunarDate(
                                        event.targetDate, repeatCycle: event.repeatCycle)
                                )
                                .font(.body)
                            } else {
                                Text(
                                    DateFormatUtils.formattedDate(
                                        event.targetDate, repeatCycle: event.repeatCycle)
                                )
                                .font(.body)
                            }
                        }

                        if event.repeatCycle != .none, let nextDate = event.nextOccurrence() {
                            HStack(alignment: .center, spacing: 0) {
                                Text("下次日期")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Text("·")
                                    .font(.body)
                                Text(DateFormatUtils.formattedDate(nextDate))
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }

                        VStack(alignment: .center, spacing: 0) {
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 10))
                                path.addLine(to: CGPoint(x: 10, y: 0))
                                path.addLine(to: CGPoint(x: 20, y: 10))
                                path.closeSubpath()
                            }
                            .fill(Color(event.color).opacity(0.62))
                            .frame(width: 20, height: 10)

                            Text("\(event.isPast ? "已过去" : "还有") \(abs(event.daysRemaining)) 天")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .frame(width: 300)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(event.color).opacity(0.62))
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EventDetailView(
        countdownStore: CountdownStore(),
        eventId: UUID(),
        onBack: {},
        onEdit: {}
    )
    .frame(width: 400, height: 600)
}
