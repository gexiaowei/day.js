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
        EventFormView(
            countdownStore: countdownStore,
            title: $title,
            targetDate: $targetDate,
            selectedCalendarType: $selectedCalendarType,
            selectedRepeatCycle: $selectedRepeatCycle,
            selectedColor: $selectedColor,
            note: $note,
            imageData: $imageData,
            formTitle: "添加事件",
            leftButton: ("xmark.circle.fill", dismiss.callAsFunction),
            rightButton: ("checkmark.circle.fill", saveEvent)
        )
        .frame(width: 350)
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