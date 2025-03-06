import SwiftUI
import PhotosUI
import AppKit

struct EventDetailView: View {
    @ObservedObject var countdownStore: CountdownStore
    let event: CountdownEvent
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 倒计时显示
                HStack {
                    Spacer()
                    VStack(spacing: 5) {
                        Text("\(abs(event.daysRemaining))")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(Color(event.color))
                        
                        Text(event.isPast ? "天前" : "天后")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 30)
                
                // 如果有图片，显示图片
                if let imageData = event.imageData, let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Rectangle())
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // 事件信息
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("标题:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(event.title)
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("日历类型:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(event.calendarType.rawValue)
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("日期:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        if event.calendarType == .lunar {
                            Text(formattedLunarDate(event.targetDate))
                                .font(.headline)
                        } else {
                            Text(formattedDate(event.targetDate))
                                .font(.headline)
                        }
                    }
                    
                    // 如果是农历，显示对应的公历日期
                    if event.calendarType == .lunar {
                        HStack {
                            Text("公历日期:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(formattedDate(event.targetDate))
                                .font(.headline)
                        }
                    }
                    
                    HStack {
                        Text("重复周期:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(event.repeatCycle.rawValue)
                            .font(.headline)
                    }
                    
                    if event.repeatCycle != .none, let nextDate = event.nextOccurrence() {
                        HStack {
                            Text("下次日期:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(formattedDate(nextDate))
                                .font(.headline)
                        }
                        
                        // 如果是农历，显示下次日期的农历表示
                        if event.calendarType == .lunar {
                            HStack {
                                Text("下次农历:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(formattedLunarDate(nextDate))
                                    .font(.headline)
                            }
                        }
                    }
                    
                    if !event.note.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("备注:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(event.note)
                                .padding(.top, 5)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(event.title)
        .toolbar {
            Button("编辑") {
                isEditing = true
            }
        }
        .popover(isPresented: $isEditing) {
            EditEventView(countdownStore: countdownStore, event: event)
                .frame(width: 350, height: 600)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
    
    private func formattedLunarDate(_ date: Date) -> String {
        return LunarDateConverter.formatLunarDate(from: date)
    }
}

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var countdownStore: CountdownStore
    let event: CountdownEvent
    
    @State private var title: String
    @State private var targetDate: Date
    @State private var selectedCalendarType: CalendarType
    @State private var selectedRepeatCycle: RepeatCycle
    @State private var selectedColor: String
    @State private var note: String
    @State private var imageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    
    let colorOptions = ["blue", "green", "red", "purple", "orange", "pink"]
    
    init(countdownStore: CountdownStore, event: CountdownEvent) {
        self.countdownStore = countdownStore
        self.event = event
        
        _title = State(initialValue: event.title)
        _targetDate = State(initialValue: event.targetDate)
        _selectedCalendarType = State(initialValue: event.calendarType)
        _selectedRepeatCycle = State(initialValue: event.repeatCycle)
        _selectedColor = State(initialValue: event.color)
        _note = State(initialValue: event.note)
        _imageData = State(initialValue: event.imageData)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(spacing: 20) {
                    eventInfoSection
                    imageSection
                    colorSection
                    noteSection
                }
                .padding(.vertical)
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("编辑事件")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button {
                deleteEvent()
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            
            Button {
                saveEvent()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.accentColor)
            }
            .disabled(title.isEmpty)
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Event Info Section
    private var eventInfoSection: some View {
        GroupBox(label: 
            Label("事件信息", systemImage: "info.circle")
                .font(.headline)
        ) {
            VStack(spacing: 16) {
                titleInputView
                calendarTypeView
                datePickerView
                repeatCycleView
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    private var titleInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("标题")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("输入事件标题", text: $title)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 4)
        }
    }
    
    private var calendarTypeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("日历类型")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("日历类型", selection: $selectedCalendarType) {
                ForEach(CalendarType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var datePickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("目标日期")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            DatePicker("选择日期", selection: $targetDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
        }
    }
    
    private var repeatCycleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("重复周期")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("重复周期", selection: $selectedRepeatCycle) {
                ForEach(RepeatCycle.allCases, id: \.self) { cycle in
                    Label(
                        title: { Text(cycle.rawValue) },
                        icon: { Image(systemName: cycleIcon(for: cycle)) }
                    )
                    .tag(cycle)
                }
            }
            .pickerStyle(.menu)
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        GroupBox(label: 
            Label("图片", systemImage: "photo")
                .font(.headline)
        ) {
            VStack {
                if let imageData = imageData, let nsImage = NSImage(data: imageData) {
                    imagePreviewView(nsImage: nsImage)
                } else {
                    imagePickerButton
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    private func imagePreviewView(nsImage: NSImage) -> some View {
        VStack {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical, 5)
            
            Button(action: {
                self.imageData = nil
            }) {
                Label("删除图片", systemImage: "trash")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
    }
    
    private var imagePickerButton: some View {
        Button(action: {
            openImagePicker()
        }) {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                
                Text("选择本地图片")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Color Section
    private var colorSection: some View {
        GroupBox(label: 
            Label("颜色", systemImage: "paintpalette")
                .font(.headline)
        ) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                ForEach(colorOptions, id: \.self) { color in
                    colorCircleView(for: color)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    private func colorCircleView(for color: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(color))
                .frame(width: 50, height: 50)
            
            if color == selectedColor {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 54, height: 54)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onTapGesture {
            selectedColor = color
        }
        .padding(5)
    }
    
    // MARK: - Note Section
    private var noteSection: some View {
        GroupBox(label: 
            Label("备注", systemImage: "note.text")
                .font(.headline)
        ) {
            TextEditor(text: $note)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
                .padding()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    private func saveEvent() {
        let updatedEvent = CountdownEvent(
            id: event.id,
            title: title,
            targetDate: targetDate,
            calendarType: selectedCalendarType,
            repeatCycle: selectedRepeatCycle,
            color: selectedColor,
            note: note,
            imageData: imageData
        )
        countdownStore.updateEvent(updatedEvent)
        dismiss()
    }
    
    private func deleteEvent() {
        if let index = countdownStore.events.firstIndex(where: { $0.id == event.id }) {
            countdownStore.deleteEvent(at: IndexSet([index]))
            NotificationCenter.default.post(name: NSNotification.Name("ReturnToEventList"), object: nil)
            dismiss()
        }
    }
    
    private func openImagePicker() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [.image]
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                do {
                    let imageData = try Data(contentsOf: url)
                    self.imageData = imageData
                } catch {
                    print("无法加载图片: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func cycleIcon(for cycle: RepeatCycle) -> String {
        switch cycle {
        case .none:
            return "xmark.circle"
        case .daily:
            return "clock"
        case .monthly:
            return "calendar"
        case .yearly:
            return "calendar.badge.clock"
        }
    }
} 