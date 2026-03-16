//
//  EmotionRecordDTO.swift
//  Mote
//
//  Created by 홍정연 on 3/5/26.
//

import Foundation
import FirebaseFirestore

struct EmotionRecordDTO {
    let emotion: String
    let caption: String
    let dateKey: String
    let yearMonth: String
    let day: Int
    let createdAt: Date?
    let updatedAt: Date?

    init(data: [String: Any], dateKey: String) {
        self.emotion = data["emotion"] as? String ?? ""

        self.caption = data["caption"] as? String ?? ""

        self.dateKey = dateKey
        self.yearMonth = data["yearMonth"] as? String ?? ""
        self.day = data["day"] as? Int ?? 0

        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        self.updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
    }

    func toDomain() -> EmotionRecord {
        EmotionRecord(
            emotion: self.emotion,
            caption: self.caption,
            dateKey: self.dateKey,
            yearMonth: self.yearMonth,
            day: self.day,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

