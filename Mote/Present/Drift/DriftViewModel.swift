//
//  DriftViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation
import RxSwift
import RxCocoa

final class DriftViewModel {
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let recentEmotions = BehaviorRelay<[EmotionRecord]>(value: [])
    let fetchFailed = PublishRelay<Error>()
    
    private let fetchRecentEmotionsUseCase: FetchRecentEmotionsUseCase
    
    init(fetchRecentEmotionsUseCase: FetchRecentEmotionsUseCase) {
        self.fetchRecentEmotionsUseCase = fetchRecentEmotionsUseCase
    }
    
    func fetchRecentEmotions() {
        guard self.isLoading.value == false else { return }
        
        self.isLoading.accept(true)
        self.fetchRecentEmotionsUseCase.execute(limit: 30) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading.accept(false)
                
                switch result {
                case .success(let emotions):
                    self.recentEmotions.accept(emotions)
                case .failure(let error):
                    self.fetchFailed.accept(error)
                }
            }
        }
    }
}
