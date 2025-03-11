import SwiftUI

struct EventEditView: View {
    @ObservedObject var countdownStore: CountdownStore
    let eventId: UUID
    let onBack: () -> Void
    let onSave: () -> Void

    // 从事件ID获取事件数据
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

    // 编辑状态
    @State private var title: String = ""
    @State private var targetDate: Date = Date()
    @State private var selectedCalendarType: CalendarType = .gregorian
    @State private var selectedRepeatCycle: RepeatCycle = .none
    @State private var selectedColor: String = "SORA"
    @State private var imageData: Data? = nil

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(event.title)
                    .font(.system(size: 20, weight: .bold))
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: saveEvent) {
                    Text("保存")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // 表单
            EventFormView(
                countdownStore: countdownStore,
                title: $title,
                targetDate: $targetDate,
                selectedCalendarType: $selectedCalendarType,
                selectedRepeatCycle: $selectedRepeatCycle,
                selectedColor: $selectedColor,
                imageData: $imageData
            )
        }
        .onAppear {
            // 初始化表单数据
            title = event.title
            targetDate = event.targetDate
            selectedCalendarType = event.calendarType
            selectedRepeatCycle = event.repeatCycle
            selectedColor = event.color
            imageData = event.imageData
        }
    }

    private func saveEvent() {
        // 创建更新后的事件
        let updatedEvent = CountdownEvent(
            id: eventId,
            title: title,
            targetDate: targetDate,
            calendarType: selectedCalendarType,
            repeatCycle: selectedRepeatCycle,
            color: selectedColor,
            imageData: imageData
        )

        // 更新事件
        countdownStore.updateEvent(updatedEvent)

        // 调用保存回调
        onSave()
    }
}

#Preview {
    EventEditView(
        countdownStore: CountdownStore(),
        eventId: UUID(),
        onBack: {},
        onSave: {}
    )
    .frame(width: 400, height: 600)
}
