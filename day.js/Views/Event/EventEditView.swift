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

            // 编辑表单
            ScrollView {
                VStack(spacing: 20) {
                    // 标题输入
                    TextField("事件标题", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // 日期选择器
                    DatePicker("目标日期", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    // 日历类型选择
                    Picker("日历类型", selection: $selectedCalendarType) {
                        ForEach(CalendarType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // 重复周期选择
                    Picker("重复周期", selection: $selectedRepeatCycle) {
                        ForEach(RepeatCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // 颜色选择
                    HStack {
                        Text("事件颜色")
                        Spacer()
                        ColorPicker(
                            "",
                            selection: Binding(
                                get: { Color(hex: color) },
                                set: { color = $0.toHex() ?? "blue" }
                            ))
                    }
                    .padding(.horizontal)

                    // 图片选择
                    Button {
                        showingImagePicker = true
                    } label: {
                        HStack {
                            Text("选择图片")
                            Spacer()
                            if let imageData = imageData,
                                let nsImage = NSImage(data: imageData)
                            {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
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
