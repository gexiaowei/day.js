import Foundation
import SwiftUI

public enum CalendarType: String, Codable, CaseIterable {
    case gregorian = "公历"
    case lunar = "农历"
}

public enum RepeatCycle: String, Codable, CaseIterable {
    case none = "不重复"
    case monthly = "每月"
    case yearly = "每年"
}

public struct CountdownEvent: Identifiable, Codable {
    public var id = UUID()
    public var title: String
    public var targetDate: Date
    public var calendarType: CalendarType
    public var repeatCycle: RepeatCycle
    public var color: String  // 存储颜色的字符串表示
    public var imageData: Data?  // 存储用户上传的图片数据

    // 编码和解码自定义图片数据
    enum CodingKeys: String, CodingKey {
        case id, title, targetDate, calendarType, repeatCycle, color, imageData
    }

    public init(
        id: UUID = UUID(), title: String, targetDate: Date, calendarType: CalendarType,
        repeatCycle: RepeatCycle, color: String, imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.calendarType = calendarType
        self.repeatCycle = repeatCycle
        self.color = color
        self.imageData = imageData
    }

    public var daysRemaining: Int {
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

    public var isPast: Bool {
        // 如果有重复周期，则永远不会过期
        if repeatCycle != .none {
            return false
        }
        return daysRemaining < 0
    }

    // 获取下一个重复日期
    public func nextOccurrence(after date: Date = Date()) -> Date? {
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
        case .monthly:
            // 如果是每月重复，返回下个月的相同日期
            // 首先检查目标日期是否已经过去
            let targetDay = targetComponents.day!
            let _ = targetComponents.month!

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
