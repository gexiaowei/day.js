import SwiftUI
import PhotosUI
import AppKit

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
    @State private var showDeleteAlert = false
    
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
        EventFormView(
            countdownStore: countdownStore,
            title: $title,
            targetDate: $targetDate,
            selectedCalendarType: $selectedCalendarType,
            selectedRepeatCycle: $selectedRepeatCycle,
            selectedColor: $selectedColor,
            note: $note,
            imageData: $imageData,
            formTitle: "编辑事件",
            leftButton: ("trash", { showDeleteAlert = true }),
            rightButton: ("checkmark.circle.fill", saveEvent)
        )
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("确定要删除这个事件吗？此操作无法撤销。")
        }
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
} 