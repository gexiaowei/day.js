// Start of Selection
import AppKit
import SwiftUI

struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var countdownStore: CountdownStore

    @Binding var title: String
    @Binding var targetDate: Date
    @Binding var selectedCalendarType: CalendarType
    @Binding var selectedRepeatCycle: RepeatCycle
    @Binding var selectedColor: String
    @Binding var imageData: Data?

    let colorOptions = ["blue", "green", "red", "purple", "orange", "pink"]
    let formTitle: String
    let leftButton: (String, () -> Void)?
    let rightButton: (String, () -> Void)

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // 图片
                ZStack {
                    Circle()
                        .fill(Color(selectedColor))  // 使用 color 参数并设置透明度
                        .frame(width: 160, height: 160)  // 圆形尺寸
                        .opacity(0.38)
                    Circle()
                        .fill(Color(selectedColor))  // 使用 color 参数并设置透明度
                        .frame(width: 145, height: 145)  // 圆形尺寸
                        .opacity(0.62)
                    if let imageData = imageData, let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                            .onTapGesture {
                                openImagePicker()
                            }
                    } else {
                         Image(systemName: "gift")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            openImagePicker()
                        }
                }

                // 标题
                TextField("输入事件标题", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 18))
                    .frame(maxWidth: .infinity)
                // 重复周期

                HStack {
                    Text("重复周期")
                    Spacer()
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
                    .frame(width: 100)
                }
                // 日历类型
                HStack {
                    Text("日历类型")
                    Spacer()
                    Picker("", selection: $selectedCalendarType) {
                        ForEach(CalendarType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }

                // 目标日期
                HStack {
                    Text("目标日期")
                    Spacer()
                    DatePicker("", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                        .frame(width: 100)
                }

                // 颜色
                HStack {
                    Text("颜色")
                    Spacer()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 24))], spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            colorCircleView(for: color)
                                .frame(width: 24, height: 24)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                        }
                    }.frame(width: 200)
                }

            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func imagePreviewView(nsImage: NSImage) -> some View {
        VStack {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFill()
                .frame(width: 220, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical, 5)

            Button {
                self.imageData = nil
            } label: {
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
        Button {
            openImagePicker()
        } label: {
            VStack(spacing: 12) {
                SFSymbolIcon(symbol: .image, size: 40, color: .accentColor).themeAware()
                Text("选择本地图片")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            .frame(width: 220, height: 150)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func colorCircleView(for color: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(color))
                .frame(width: 20, height: 20)

            if color == selectedColor {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 20, height: 20)

                SFSymbolIcon(symbol: .check, size: 10, color: .white).themeAware()
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
        case .monthly:
            return "calendar"
        case .yearly:
            return "calendar.badge.clock"
        }
    }
}
