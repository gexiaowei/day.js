import Foundation

struct CountdownEvent: Identifiable, Codable {
    var id = UUID()
    var title: String
    var targetDate: Date
    var color: String // 存储颜色的字符串表示
    var note: String
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day ?? 0
    }
    
    var isPast: Bool {
        return daysRemaining < 0
    }
}

class CountdownStore: ObservableObject {
    @Published var events: [CountdownEvent] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                   in: .userDomainMask,
                                   appropriateFor: nil,
                                   create: true)
            .appendingPathComponent("countdownEvents.data")
    }
    
    func load() {
        do {
            let fileURL = try CountdownStore.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                // 如果文件不存在，使用空数组
                events = []
                return
            }
            let decodedEvents = try JSONDecoder().decode([CountdownEvent].self, from: data)
            events = decodedEvents
        } catch {
            print("加载倒计时事件失败: \(error.localizedDescription)")
            events = []
        }
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(events)
            let outfile = try CountdownStore.fileURL()
            try data.write(to: outfile)
        } catch {
            print("保存倒计时事件失败: \(error.localizedDescription)")
        }
    }
    
    func addEvent(_ event: CountdownEvent) {
        events.append(event)
        save()
    }
    
    func deleteEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        save()
    }
    
    func updateEvent(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            save()
        }
    }
} 