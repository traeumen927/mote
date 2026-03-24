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
    let gravityOption: BehaviorRelay<GravityOption>
    let bounceOption: BehaviorRelay<BounceOption>
    
    private let fetchMoteSizeUseCase: FetchMoteSizeUseCase
    private let updateMoteSizeUseCase: UpdateMoteSizeUseCase
    private let updateGravityOptionUseCase: UpdateGravityOptionUseCase
    private let updateBounceOptionUseCase: UpdateBounceOptionUseCase
    
    init(
        fetchMoteSizeUseCase: FetchMoteSizeUseCase,
        updateMoteSizeUseCase: UpdateMoteSizeUseCase,
        fetchGravityOptionUseCase: FetchGravityOptionUseCase,
        updateGravityOptionUseCase: UpdateGravityOptionUseCase,
        fetchBounceOptionUseCase: FetchBounceOptionUseCase,
        updateBounceOptionUseCase: UpdateBounceOptionUseCase
    ) {
        self.fetchMoteSizeUseCase = fetchMoteSizeUseCase
        self.updateMoteSizeUseCase = updateMoteSizeUseCase
        self.updateGravityOptionUseCase = updateGravityOptionUseCase
        self.updateBounceOptionUseCase = updateBounceOptionUseCase
        self.moteSizeOption = BehaviorRelay(value: fetchMoteSizeUseCase.execute())
        self.gravityOption = BehaviorRelay(value: fetchGravityOptionUseCase.execute())
        self.bounceOption = BehaviorRelay(value: fetchBounceOptionUseCase.execute())
    }
    
    func updateMoteSizeOption(_ sizeOption: MoteSizeOption) {
        self.updateMoteSizeUseCase.execute(sizeOption)
        self.moteSizeOption.accept(sizeOption)
    }
    
    func updateGravityOption(_ gravityOption: GravityOption) {
        self.updateGravityOptionUseCase.execute(gravityOption)
        self.gravityOption.accept(gravityOption)
    }
    
    func updateBounceOption(_ bounceOption: BounceOption) {
        self.updateBounceOptionUseCase.execute(bounceOption)
        self.bounceOption.accept(bounceOption)
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
