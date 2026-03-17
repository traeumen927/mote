//
//  MotesViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/16/26.
//

import Foundation

final class MotesViewModel {
    func makeRandomEmotionRecords(limit: Int) -> [EmotionRecord] {
        guard limit > 0 else { return [] }
        
        return (0..<limit).map { index in
            let emotion = EmotionItem.allCases.randomElement()?.rawValue ?? EmotionItem.happy.rawValue
            
            return EmotionRecord(
                emotion: emotion,
                caption: "",
                dateKey: "motes-random-\(index)",
                yearMonth: "",
                day: 0,
                createdAt: nil,
                updatedAt: nil
            )
        }
    }
}
