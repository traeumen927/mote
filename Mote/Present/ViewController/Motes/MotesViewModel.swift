//
//  MotesViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/16/26.
//

import Foundation
import RxSwift
import RxCocoa

final class MotesViewModel {
    
    let moteSizeOption: BehaviorRelay<MoteSizeOption>
    
    private let fetchMoteSizeUseCase: FetchMoteSizeUseCase
    private let updateMoteSizeUseCase: UpdateMoteSizeUseCase
    
    init(
        fetchMoteSizeUseCase: FetchMoteSizeUseCase,
        updateMoteSizeUseCase: UpdateMoteSizeUseCase
    ) {
        self.fetchMoteSizeUseCase = fetchMoteSizeUseCase
        self.updateMoteSizeUseCase = updateMoteSizeUseCase
        self.moteSizeOption = BehaviorRelay(value: fetchMoteSizeUseCase.execute())
    }
    
    func updateMoteSizeOption(_ sizeOption: MoteSizeOption) {
        self.updateMoteSizeUseCase.execute(sizeOption)
        self.moteSizeOption.accept(sizeOption)
    }
    
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
