import SwiftUI
import PhotosUI
import AppKit

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var countdownStore: CountdownStore
    
    @State private var title = ""
    @State private var targetDate = Date()
    @State private var selectedCalendarType = CalendarType.solar
    @State private var selectedRepeatCycle = RepeatCycle.none
    @State private var selectedColor = "blue"
    @State private var note = ""
    @State private var imageData: Data?
    @State private var showingFileImporter = false
    
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
            .navigationTitle("添加新事件")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let newEvent = CountdownEvent(
                            title: title,
                            targetDate: targetDate,
                            calendarType: selectedCalendarType,
                            repeatCycle: selectedRepeatCycle,
                            color: selectedColor,
                            note: note,
                            imageData: imageData
                        )
                        countdownStore.addEvent(newEvent)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

extension Color {
    init(_ colorName: String) {
        switch colorName {
        case "blue":
            self = .blue
        case "green":
            self = .green
        case "red":
            self = .red
        case "purple":
            self = .purple
        case "orange":
            self = .orange
        case "pink":
            self = .pink
        default:
            self = .blue
        }
    }
} 