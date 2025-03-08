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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("标题")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("输入事件标题", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 300)
                }
                
                // Calendar Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("日历类型")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $selectedCalendarType) {
                        ForEach(CalendarType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }
                
                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("目标日期")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .frame(maxWidth: .infinity)
                }
                
                // Repeat Cycle
                VStack(alignment: .leading, spacing: 8) {
                    Text("重复周期")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $selectedRepeatCycle) {
                        ForEach(RepeatCycle.allCases, id: \.self) { cycle in
                            Label(
                                title: { Text(cycle.rawValue) },
                                icon: { Image(systemName: cycleIcon(for: cycle)) }
                            )
                            .tag(cycle)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 300)
                }
                
                // Colors
                VStack(alignment: .leading, spacing: 8) {
                    Text("颜色")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            colorCircleView(for: color)
                        }
                    }
                    .frame(width: 300)
                }
                
                // Image
                VStack(alignment: .leading, spacing: 8) {
                    Text("图片")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let imageData = imageData, let nsImage = NSImage(data: imageData) {
                        imagePreviewView(nsImage: nsImage)
                    } else {
                        imagePickerButton
                    }
                }
                
                // Note
                VStack(alignment: .leading, spacing: 8) {
                    Text("备注")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $note)
                        .frame(width: 300, height: 100)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func imagePreviewView(nsImage: NSImage) -> some View {
        VStack {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical, 5)
            
            Button(action: {
                self.imageData = nil
            }) {
                Label("删除图片", systemImage: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
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
            .frame(width: 300, height: 150)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func colorCircleView(for color: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(color))
                .frame(width: 30, height: 30)
            
            if color == selectedColor {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 34, height: 34)
                
                SFSymbolIcon(symbol: .check, size: 12, color: .white).themeAware()
            }
        }
        .onTapGesture {
            selectedColor = color
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