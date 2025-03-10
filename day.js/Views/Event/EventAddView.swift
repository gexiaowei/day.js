import AppKit
import SwiftUI

struct EventAddView: View {
    @ObservedObject var countdownStore: CountdownStore
    let onBack: () -> Void
    let onSave: () -> Void

    // 添加事件的状态
    @State private var title: String = ""
    @State private var targetDate: Date = Date()
    @State private var selectedCalendarType: CalendarType = .gregorian
    @State private var selectedRepeatCycle: RepeatCycle = .none
    @State private var color: String = "blue"
    @State private var imageData: Data?
    @State private var showingImagePicker = false

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

                Text("添加事件")
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

            // 添加表单
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
        // 验证必填字段
        guard !title.isEmpty else { return }

        // 创建新事件
        let newEvent = CountdownEvent(
            title: title,
            targetDate: targetDate,
            calendarType: selectedCalendarType,
            repeatCycle: selectedRepeatCycle,
            color: color,
            imageData: imageData
        )

        // 添加事件
        countdownStore.addEvent(newEvent)

        // 重置表单
        title = ""
        targetDate = Date()
        selectedCalendarType = .gregorian
        selectedRepeatCycle = .none
        color = "blue"
        imageData = nil
    }
}

#Preview {
    EventAddView(
        countdownStore: CountdownStore(),
        onBack: {},
        onSave: {}
    )
}
