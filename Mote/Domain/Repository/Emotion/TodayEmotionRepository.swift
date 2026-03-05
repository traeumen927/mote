//
//  TodayEmotionRepository.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation

protocol TodayEmotionRepository {
    
    @discardableResult
    func observeTodayEmotion(
        request: ObserveTodayEmotionRequest,
        onChange: @escaping (Result<EmotionRecord?, Error>) -> Void
    ) -> (() -> Void)
    
    func saveTodayEmotion(
        request: SaveTodayEmotionRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
