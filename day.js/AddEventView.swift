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
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.leading)
                
                Spacer()
                
                Text("添加事件")
                    .font(.headline)
                
                Spacer()
                
                Button(action: saveEvent) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))
            
            // 分隔线
            Divider()
            
            EventFormView(
                countdownStore: countdownStore,
                title: $title,
                targetDate: $targetDate,
                selectedCalendarType: $selectedCalendarType,
                selectedRepeatCycle: $selectedRepeatCycle,
                selectedColor: $selectedColor,
                note: $note,
                imageData: $imageData
            )
        }
    }
    
    // MARK: - Helper Methods
    private func saveEvent() {
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