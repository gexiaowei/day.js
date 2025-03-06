import Foundation

/// 农历日期转换工具
class LunarDateConverter {
    // 农历月份名称
    private static let lunarMonths = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"]
    
    // 农历日期名称
    private static let lunarDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                                   "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                                   "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
    /// 获取农历日期的组件
    /// - Parameter date: 公历日期
    /// - Returns: 农历年、月、日的元组
    static func getLunarComponents(from date: Date) -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar(identifier: .chinese)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return (components.year!, components.month!, components.day!)
    }
    
    /// 从农历日期获取公历日期
    /// - Parameters:
    ///   - lunarYear: 农历年
    ///   - lunarMonth: 农历月
    ///   - lunarDay: 农历日
    /// - Returns: 公历日期
    static func solarDateFrom(lunarYear: Int, lunarMonth: Int, lunarDay: Int) -> Date? {
        let calendar = Calendar(identifier: .chinese)
        var components = DateComponents()
        components.year = lunarYear
        components.month = lunarMonth
        components.day = lunarDay
        components.hour = 12
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)
    }
    
    /// 获取下一个农历重复日期
    /// - Parameters:
    ///   - date: 原始公历日期
    ///   - repeatCycle: 重复周期
    /// - Returns: 下一个重复日期（公历）
    static func nextLunarDate(from date: Date, repeatCycle: RepeatCycle) -> Date? {
        guard repeatCycle != .none else { return nil }
        
        // 获取当前日期的农历组件
        let lunarComponents = getLunarComponents(from: date)
        
        // 根据重复周期计算下一个农历日期
        var nextLunarYear = lunarComponents.year
        var nextLunarMonth = lunarComponents.month
        var nextLunarDay = lunarComponents.day
        
        switch repeatCycle {
        case .daily:
            // 每天重复，直接返回明天
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())
            
        case .monthly:
            // 每月重复，农历月份加1
            nextLunarMonth += 1
            if nextLunarMonth > 12 {
                nextLunarMonth = 1
                nextLunarYear += 1
            }
            
        case .yearly:
            // 每年重复，农历年份加1
            nextLunarYear += 1
            
        case .none:
            return nil
        }
        
        // 转换为公历日期
        return solarDateFrom(lunarYear: nextLunarYear, lunarMonth: nextLunarMonth, lunarDay: nextLunarDay)
    }
    
    /// 格式化农历日期为字符串
    /// - Parameter date: 公历日期
    /// - Returns: 农历日期字符串
    static func formatLunarDate(from date: Date) -> String {
        let lunarComponents = getLunarComponents(from: date)
        let lunarYear = lunarComponents.year
        let lunarMonth = lunarComponents.month
        let lunarDay = lunarComponents.day
        
        let monthName = lunarMonths[lunarMonth - 1]
        let dayName = lunarDays[lunarDay - 1]
        
        return "\(lunarYear)年\(monthName)月\(dayName)"
    }
} 