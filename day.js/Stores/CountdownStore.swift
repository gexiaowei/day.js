import Foundation
import SwiftUI

class CountdownStore: ObservableObject {
    @Published public var events: [CountdownEvent] = []

    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("countdownEvents.data")
    }

    public func load() {
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

    public func save() {
        do {
            let data = try JSONEncoder().encode(events)
            let outfile = try CountdownStore.fileURL()
            try data.write(to: outfile)
        } catch {
            print("保存倒计时事件失败: \(error.localizedDescription)")
        }
    }

    public func addEvent(_ event: CountdownEvent) {
        events.append(event)
        save()
    }

    public func deleteEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        save()
    }

    public func deleteEvent(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        save()
    }

    public func updateEvent(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            save()
        }
    }
}
