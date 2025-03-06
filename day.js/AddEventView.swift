import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var countdownStore: CountdownStore
    
    @State private var title = ""
    @State private var targetDate = Date()
    @State private var selectedColor = "blue"
    @State private var note = ""
    
    let colorOptions = ["blue", "green", "red", "purple", "orange", "pink"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("事件信息")) {
                    TextField("标题", text: $title)
                    DatePicker("目标日期", selection: $targetDate, displayedComponents: .date)
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
                            color: selectedColor,
                            note: note
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