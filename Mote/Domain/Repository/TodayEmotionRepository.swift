//
//  TodayEmotionRepository.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation

protocol TodayEmotionRepository {
    func saveTodayEmotion(
        uid: String,
        emotion: String,
        caption: String?,
        dateKey: String,
        yearMonth: String,
        day: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
