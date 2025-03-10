import Foundation

class DateFormatUtils {

    static func formattedDate(_ date: Date, repeatCycle: RepeatCycle) -> String {
        let formatter = DateFormatter()
        switch repeatCycle {
        case .yearly:
            formatter.dateFormat = "MM月dd日"
        case .monthly:
            formatter.dateFormat = "dd日"
        default:
            formatter.dateFormat = "yyyy年MM月dd日"
        }
        return formatter.string(from: date)
    }

    static func formattedLunarDate(_ date: Date, repeatCycle: RepeatCycle) -> String {
        let lunarString = LunarDateConverter.formatLunarDate(from: date)
        switch repeatCycle {
        case .yearly:
            if let regex = try? Regex("[0-9]+年") {
                return lunarString.replacing(regex, with: "")
            }
            return lunarString
        case .monthly:
            let components = lunarString.components(separatedBy: "月")
            guard components.count > 1 else { return lunarString }
            return components[1]
        default:
            return lunarString
        }
    }

    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    static func formattedLunarDate(_ date: Date) -> String {
        return LunarDateConverter.formatLunarDate(from: date)
    }
}
