//
//  TodayViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation

final class TodayViewModel {
    struct TodayEmotionRecord {
            let emotion: String
            let caption: String?
            let savedAt: Date
        }
        
        let items: [String] = [
            "😎 Proud",
            "🥹 Touched",
            "🤬 Furious",
            "😝 Excited",
            "🥰 Happy",
            "🙂 Okay",
            "😐 Meh",
            "☹️ Displeased",
            "😭 Sad"
        ]
        
        private let userDefaults: UserDefaults
        private let calendar: Calendar
        private let savedDateKey = "today_emotion_saved_date"
        
        init(userDefaults: UserDefaults = .standard, calendar: Calendar = .current) {
            self.userDefaults = userDefaults
            self.calendar = calendar
        }
        
        func canSaveToday() -> Bool {
            guard let savedDate = self.userDefaults.object(forKey: self.savedDateKey) as? Date else {
                return true
            }
            return !self.calendar.isDateInToday(savedDate)
        }
        
        @discardableResult
        func saveTodayEmotion(selectedIndex: Int, caption: String?) -> TodayEmotionRecord? {
            guard self.canSaveToday(), self.items.indices.contains(selectedIndex) else {
                return nil
            }
            
            let normalizedCaption = caption?.trimmingCharacters(in: .whitespacesAndNewlines)
            let record = TodayEmotionRecord(
                emotion: self.items[selectedIndex],
                caption: normalizedCaption?.isEmpty == true ? nil : normalizedCaption,
                savedAt: Date()
            )
            
            self.userDefaults.set(record.savedAt, forKey: self.savedDateKey)
            return record
        }
}
