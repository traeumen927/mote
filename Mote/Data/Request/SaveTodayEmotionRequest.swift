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
    let dateKey: String
    let yearMonth: String
    let day: Int
}
