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
        .sheet(isPresented: $isEditing) {
            EditEventView(countdownStore: countdownStore, event: event)
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
    @State private var showingFileImporter = false
    
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
    
    let colorOptions = ["blue", "green", "red", "purple", "orange", "pink"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("事件信息")) {
                    TextField("标题", text: $title)
                    
                    Picker("日历类型", selection: $selectedCalendarType) {
                        ForEach(CalendarType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("目标日期", selection: $targetDate, displayedComponents: .date)
                    
                    Picker("重复周期", selection: $selectedRepeatCycle) {
                        ForEach(RepeatCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                }
                
                Section(header: Text("图片")) {
                    VStack {
                        if let imageData = imageData, let nsImage = NSImage(data: imageData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Rectangle())
                                .cornerRadius(8)
                                .padding(.vertical, 5)
                            
                            Button("删除图片") {
                                self.imageData = nil
                            }
                            .foregroundColor(.red)
                        } else {
                            Button("选择本地图片") {
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
                        }
                    }
                }
                
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))]) {
                        ForEach(colorOptions, id: \.self) { color in
                            ZStack {
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 30, height: 30)
                                
                                if color == selectedColor {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                            .padding(5)
                        }
                    }
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("编辑事件")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
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
                    .disabled(title.isEmpty)
                }
            }
        }
    }
} 