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
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .padding(.leading)
                
                Spacer()
                
                Text("编辑事件")
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