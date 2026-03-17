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
    private let fetchMoteSizeUseCase: FetchMoteSizeUseCase
    private var activeRequestID: UUID?
    
    init(fetchRecentEmotionsUseCase: FetchRecentEmotionsUseCase,
         fetchMoteSizeUseCase: FetchMoteSizeUseCase
    ) {
        self.fetchRecentEmotionsUseCase = fetchRecentEmotionsUseCase
        self.fetchMoteSizeUseCase = fetchMoteSizeUseCase
    }
    
    func fetchRecentEmotions() {
        guard self.isLoading.value == false else { return }
        
        let requestID = UUID()
        self.activeRequestID = requestID
        
        self.isLoading.accept(true)
        self.fetchRecentEmotionsUseCase.execute(limit: 30) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                guard self.activeRequestID == requestID else { return }
                
                self.activeRequestID = nil
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
    
    func cancelOngoingEventsAndClearItems() {
        self.activeRequestID = nil
        self.isLoading.accept(false)
        self.recentEmotions.accept([])
    }
}
