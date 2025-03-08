import SwiftUI
import AppKit

struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var countdownStore: CountdownStore
    
    @Binding var title: String
    @Binding var targetDate: Date
    @Binding var selectedCalendarType: CalendarType
    @Binding var selectedRepeatCycle: RepeatCycle
    @Binding var selectedColor: String
    @Binding var note: String
    @Binding var imageData: Data?
    
    let colorOptions = ["blue", "green", "red", "purple", "orange", "pink"]
    let formTitle: String
    let leftButton: (String, () -> Void)?
    let rightButton: (String, () -> Void)
    
    var body: some View {
        VStack(spacing: 0) {
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
                SFSymbolIcon(symbol: .image, size: 40, color: .accentColor).themeAware()
                
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
                
                SFSymbolIcon(symbol: .check, size: 16, color: .white).themeAware()
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