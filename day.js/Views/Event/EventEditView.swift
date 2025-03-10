import SwiftUI

struct EventEditView: View {
    @ObservedObject var countdownStore: CountdownStore
    let event: CountdownEvent
    let onBack: () -> Void
    let onSave: () -> Void

    // 编辑事件的状态
    @State private var title: String
    @State private var targetDate: Date
    @State private var selectedCalendarType: CalendarType
    @State private var selectedRepeatCycle: RepeatCycle
    @State private var color: String
    @State private var imageData: Data?
    @State private var showingImagePicker = false

    init(
        countdownStore: CountdownStore, event: CountdownEvent, onBack: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) {
        self.countdownStore = countdownStore
        self.event = event
        self.onBack = onBack
        self.onSave = onSave

        // 初始化状态
        _title = State(initialValue: event.title)
        _targetDate = State(initialValue: event.targetDate)
        _selectedCalendarType = State(initialValue: event.calendarType)
        _selectedRepeatCycle = State(initialValue: event.repeatCycle)
        _color = State(initialValue: event.color)
        _imageData = State(initialValue: event.imageData)
    }

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
                    saveEvent()
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

            EventFormView(
                countdownStore: countdownStore,
                title: $title,
                targetDate: $targetDate,
                selectedCalendarType: $selectedCalendarType,
                selectedRepeatCycle: $selectedRepeatCycle,
                selectedColor: $color,
                imageData: $imageData
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                guard let file = files.first else { return }
                do {
                    let data = try Data(contentsOf: file)
                    imageData = data
                } catch {
                    print("Error loading image: \(error)")
                }
            case .failure(let error):
                print("Error selecting image: \(error)")
            }
        }
    }

    private func saveEvent() {
        // 创建更新后的事件
        let updatedEvent = CountdownEvent(
            id: event.id,
            title: title,
            targetDate: targetDate,
            calendarType: selectedCalendarType,
            repeatCycle: selectedRepeatCycle,
            color: color,
            imageData: imageData
        )

        // 更新事件
        countdownStore.updateEvent(updatedEvent)
    }
}
