import Foundation

enum CalendarType: String, Codable, CaseIterable {
    case solar = "公历"
    case lunar = "农历"
}

enum RepeatCycle: String, Codable, CaseIterable {
    case none = "不重复"
    case daily = "每天"
    case monthly = "每月"
    case yearly = "每年"
}

struct CountdownEvent: Identifiable, Codable {
    var id = UUID()
    var title: String
    var targetDate: Date
    var calendarType: CalendarType
    var repeatCycle: RepeatCycle
    var color: String // 存储颜色的字符串表示
    var note: String
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        
        // 如果有重复周期，需要计算到下一个重复日期的天数
        if repeatCycle != .none {
            if let nextDate = nextOccurrence() {
                let components = calendar.dateComponents([.day], from: Date(), to: nextDate)
                return components.day ?? 0
            }
        }
        
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day ?? 0
    }
    
    var isPast: Bool {
        // 如果有重复周期，则永远不会过期
        if repeatCycle != .none {
            return false
        }
        return daysRemaining < 0
    }
    
    // 获取下一个重复日期
    func nextOccurrence(after date: Date = Date()) -> Date? {
        guard repeatCycle != .none else { return nil }
        
        // 如果是农历日期，使用农历日期转换器
        if calendarType == .lunar {
            return LunarDateConverter.nextLunarDate(from: targetDate, repeatCycle: repeatCycle)
        }
        
        // 公历日期处理逻辑
        let calendar = Calendar.current
        let targetComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        var nextComponents = DateComponents()
        
        switch repeatCycle {
        case .daily:
            // 如果是每天重复，返回明天的相同时间
            return calendar.date(byAdding: .day, value: 1, to: date)
            
        case .monthly:
            // 如果是每月重复，返回下个月的相同日期
            // 首先检查目标日期是否已经过去
            let targetDay = targetComponents.day!
            let targetMonth = targetComponents.month!
            
            // 计算当前月份的目标日期
            nextComponents.year = currentComponents.year
            nextComponents.month = currentComponents.month
            nextComponents.day = targetDay
            
            var nextDate = calendar.date(from: nextComponents)
            
            // 如果当前月的目标日期已过或当前月没有这一天
            if nextDate == nil || nextDate! <= date {
                // 移到下个月
                nextComponents.month = currentComponents.month! + 1
                if nextComponents.month! > 12 {
                    nextComponents.month = 1
                    nextComponents.year = currentComponents.year! + 1
                }
                
                // 处理月末日期问题（例如1月31日的下一个月可能没有31日）
                nextDate = calendar.date(from: nextComponents)
                if nextDate == nil {
                    // 如果日期无效，使用下个月的最后一天
                    nextComponents.day = 1
                    nextDate = calendar.date(from: nextComponents)
                    nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate!)
                    nextDate = calendar.date(byAdding: .day, value: -1, to: nextDate!)
                }
            }
            
            return nextDate
            
        case .yearly:
            // 如果是每年重复，返回今年或明年的相同日期
            let targetMonth = targetComponents.month!
            let targetDay = targetComponents.day!
            
            // 首先尝试今年的目标日期
            nextComponents.year = currentComponents.year
            nextComponents.month = targetMonth
            nextComponents.day = targetDay
            
            var nextDate = calendar.date(from: nextComponents)
            
            // 如果今年的目标日期已过或无效（如2月29日在非闰年）
            if nextDate == nil || nextDate! <= date {
                // 移到明年
                nextComponents.year = currentComponents.year! + 1
                nextDate = calendar.date(from: nextComponents)
                
                // 处理2月29日在非闰年的情况
                if nextDate == nil {
                    if targetMonth == 2 && targetDay == 29 {
                        // 如果是2月29日，在非闰年使用2月28日
                        nextComponents.day = 28
                        nextDate = calendar.date(from: nextComponents)
                    }
                }
            }
            
            return nextDate
            
        case .none:
            return nil
        }
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