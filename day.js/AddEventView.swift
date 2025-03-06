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
    
    let colorOptions = ["blue", "green", "red", "purple", "orange", "pink"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 事件信息部分
                    VStack(alignment: .leading, spacing: 16) {
                        Text("事件信息")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 16) {
                            // 标题输入
                            VStack(alignment: .leading, spacing: 8) {
                                Text("标题")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("输入事件标题", text: $title)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(8)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // 日历类型选择
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
                                .padding(8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            // 目标日期选择
                            VStack(alignment: .leading, spacing: 8) {
                                Text("目标日期")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                DatePicker("选择日期", selection: $targetDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .padding(8)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // 重复周期选择
                            VStack(alignment: .leading, spacing: 8) {
                                Text("重复周期")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("重复周期", selection: $selectedRepeatCycle) {
                                    ForEach(RepeatCycle.allCases, id: \.self) { cycle in
                                        HStack {
                                            Image(systemName: cycleIcon(for: cycle))
                                                .foregroundColor(Color(selectedColor))
                                            Text(cycle.rawValue)
                                        }
                                        .tag(cycle)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // 图片部分
                    VStack(alignment: .leading, spacing: 16) {
                        Text("图片")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        VStack {
                            if let imageData = imageData, let nsImage = NSImage(data: imageData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                                .buttonStyle(PlainButtonStyle())
                                .padding(.top, 8)
                            } else {
                                Button(action: {
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
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(selectedColor))
                                        
                                        Text("选择本地图片")
                                            .font(.headline)
                                            .foregroundColor(Color(selectedColor))
                                    }
                                    .frame(width: 250, height: 150)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // 颜色选择部分
                    VStack(alignment: .leading, spacing: 16) {
                        Text("颜色")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        VStack {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                                ForEach(colorOptions, id: \.self) { color in
                                    ZStack {
                                        Circle()
                                            .fill(Color(color))
                                            .frame(width: 50, height: 50)
                                            .shadow(color: Color(color).opacity(0.5), radius: 5, x: 0, y: 2)
                                        
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
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // 备注部分
                    VStack(alignment: .leading, spacing: 16) {
                        Text("备注")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        VStack {
                            TextEditor(text: $note)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // 保存按钮
                    Button(action: {
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
                    }) {
                        Text("保存事件")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.isEmpty ? Color.gray : Color(selectedColor))
                            .cornerRadius(12)
                            .shadow(color: title.isEmpty ? Color.gray.opacity(0.3) : Color(selectedColor).opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(title.isEmpty)
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("添加新事件")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
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