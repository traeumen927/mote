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
    let moteSizeOption = BehaviorRelay<MoteSizeOption>(value: .default)
    let gravityOption = BehaviorRelay<GravityOption>(value: .default)
    let fetchFailed = PublishRelay<Error>()
    
    private let fetchRecentEmotionsUseCase: FetchRecentEmotionsUseCase
    private let fetchMoteSizeUseCase: FetchMoteSizeUseCase
    private let fetchGravityOptionUseCase: FetchGravityOptionUseCase
    private var activeRequestID: UUID?
    
    init(fetchRecentEmotionsUseCase: FetchRecentEmotionsUseCase,
         fetchMoteSizeUseCase: FetchMoteSizeUseCase,
         fetchGravityOptionUseCase: FetchGravityOptionUseCase
    ) {
        self.fetchRecentEmotionsUseCase = fetchRecentEmotionsUseCase
        self.fetchMoteSizeUseCase = fetchMoteSizeUseCase
        self.fetchGravityOptionUseCase = fetchGravityOptionUseCase
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
    
    func fetchMotePreferences() {
        self.moteSizeOption.accept(self.fetchMoteSizeUseCase.execute())
        self.gravityOption.accept(self.fetchGravityOptionUseCase.execute())
    }
    
    func cancelOngoingEventsAndClearItems() {
        self.activeRequestID = nil
        self.isLoading.accept(false)
        self.recentEmotions.accept([])
    }
}
