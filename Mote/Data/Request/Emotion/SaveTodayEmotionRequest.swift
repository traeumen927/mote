//
//  SaveTodayEmotionRequest.swift
//  Mote
//
//  Created by 홍정연 on 3/5/26.
//

import Foundation

struct SaveTodayEmotionRequest {
    let uid: String
    let emotion: String
    let caption: String
    let isHidden: Bool
    let dateKey: String
    let yearMonth: String
    let day: Int
    
    init(
        uid: String,
        emotion: String,
        caption: String,
        isHidden: Bool = false,
        dateKey: String,
        yearMonth: String,
        day: Int
    ) {
        self.uid = uid
        self.emotion = emotion
        self.caption = caption
        self.isHidden = isHidden
        self.dateKey = dateKey
        self.yearMonth = yearMonth
        self.day = day
    }
}
