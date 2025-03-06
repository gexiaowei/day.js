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
        
        // 获取公历年份
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let gregorianYear = gregorianCalendar.component(.year, from: date)
        
        return (gregorianYear, components.month!, components.day!)
    }
    
    /// 从农历日期获取公历日期
    /// - Parameters:
    ///   - lunarYear: 农历年
    ///   - lunarMonth: 农历月
    ///   - lunarDay: 农历日
    /// - Returns: 公历日期
    static func solarDateFrom(lunarYear: Int, lunarMonth: Int, lunarDay: Int) -> Date? {
        // 首先获取公历年的第一天
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = lunarYear
        components.month = 1
        components.day = 1
        components.hour = 12
        
        guard let startOfYear = gregorianCalendar.date(from: components) else {
            return nil
        }
        
        // 然后使用农历日期查找
        let chineseCalendar = Calendar(identifier: .chinese)
        
        // 从公历年的第一天开始，找到对应的农历日期
        var currentDate = startOfYear
        let endOfYear = gregorianCalendar.date(byAdding: .year, value: 1, to: startOfYear)!
        
        while currentDate < endOfYear {
            let lunarComponents = chineseCalendar.dateComponents([.month, .day], from: currentDate)
            
            if lunarComponents.month == lunarMonth && lunarComponents.day == lunarDay {
                return currentDate
            }
            
            currentDate = gregorianCalendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // 如果在当年找不到，尝试下一年
        components.year = lunarYear + 1
        guard let nextYearStart = gregorianCalendar.date(from: components) else {
            return nil
        }
        
        currentDate = nextYearStart
        let endOfNextYear = gregorianCalendar.date(byAdding: .year, value: 1, to: nextYearStart)!
        
        while currentDate < endOfNextYear {
            let lunarComponents = chineseCalendar.dateComponents([.month, .day], from: currentDate)
            
            if lunarComponents.month == lunarMonth && lunarComponents.day == lunarDay {
                return currentDate
            }
            
            currentDate = gregorianCalendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return nil
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
        
        // 获取当前日期
        let currentDate = Date()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let currentYear = gregorianCalendar.component(.year, from: currentDate)
        
        // 根据重复周期计算下一个农历日期
        var nextLunarYear = lunarComponents.year
        var nextLunarMonth = lunarComponents.month
        var nextLunarDay = lunarComponents.day
        
        switch repeatCycle {
        case .daily:
            // 每天重复，直接返回明天
            return gregorianCalendar.date(byAdding: .day, value: 1, to: currentDate)
            
        case .monthly:
            // 每月重复，农历月份加1
            nextLunarMonth += 1
            if nextLunarMonth > 12 {
                nextLunarMonth = 1
                nextLunarYear += 1
            }
            
            // 如果计算的年份小于当前年份，则使用当前年份
            if nextLunarYear < currentYear {
                nextLunarYear = currentYear
            }
            
        case .yearly:
            // 如果目标日期已过，则使用下一年
            if nextLunarYear < currentYear || (nextLunarYear == currentYear && solarDateFrom(lunarYear: nextLunarYear, lunarMonth: nextLunarMonth, lunarDay: nextLunarDay)! < currentDate) {
                nextLunarYear = currentYear + 1
            } else {
                nextLunarYear = currentYear
            }
            
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