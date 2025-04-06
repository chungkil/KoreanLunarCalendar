//
//  Date+.swift
//  KoreanLunarCalendar
//
//  Created by CHUNGKIL KIM on 4/5/25.
//
import Foundation

public extension Date {
    
    /// 현재 날짜의 음력 날짜 정보를 반환합니다.
    /// - Returns: 음력 날짜 정보가 포함된 LunarDateInfo 구조체
    func toLunar() -> (year: Int, month: Int, day: Int, isLeapMonth: Bool)? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        
        guard let year = components.year, let month = components.month, let day = components.day else {
            return nil
        }
        
        let luna = KoreanLunarCalendar()
        let isValid = luna.setSolarDate(solarYear: year, solarMonth: month, solarDay: day)
        
        if isValid {
            return (
                year: luna.getLunarYear(),
                month: luna.getLunarMonth(),
                day: luna.getLunarDay(),
                isLeapMonth: luna.getIntercalation()
            )
        }
        return nil
    }
    
    /// 음력 날짜로부터 양력 날짜를 생성합니다.
    /// - Parameters:
    ///   - lunarYear: 음력 연도
    ///   - lunarMonth: 음력 월
    ///   - lunarDay: 음력 일
    ///   - isLeapMonth: 윤달 여부
    /// - Returns: 양력 날짜(Date) 또는 nil(변환 실패 시)
    static func fromLunar(_ year: Int, _ month: Int, _ day: Int, isLeapMonth: Bool = false) -> Date? {
        let luna = KoreanLunarCalendar()
        let isOk = luna.setLunarDate(lunarYear: year, lunarMonth: month, lunarDay: day, isIntercalation: isLeapMonth)
        
        if isOk {
            let year = luna.getSolarYear()
            let month = luna.getSolarMonth()
            let day = luna.getSolarDay()
            
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            
            return Calendar.current.date(from: dateComponents)
        }
        
        return nil
    }
}
