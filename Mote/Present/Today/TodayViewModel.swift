//
//  TodayViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation
import RxSwift
import RxCocoa

final class TodayViewModel {
    let items = EmotionItem.allCases
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let saveSucceeded = PublishRelay<SaveTodayEmotionUseCase.ResultData>()
    let saveFailed = PublishRelay<Error>()
    
    private let canSaveRelay = BehaviorRelay<Bool>(value: false)
    var canSave: Driver<Bool> {
        self.canSaveRelay.asDriver()
    }
    
    private var selectedIndex: Int?
    private var caption: String?
    
    private let saveTodayEmotionUseCase: SaveTodayEmotionUseCase
    
    init(saveTodayEmotionUseCase: SaveTodayEmotionUseCase) {
        self.saveTodayEmotionUseCase = saveTodayEmotionUseCase
    }
    
    func selectEmotion(at index: Int) {
        self.selectedIndex = index
        self.syncCanSave()
    }
    
    func updateCaption(_ caption: String?) {
        self.caption = caption
    }
    
    func saveTodayEmotion() {
        guard let selectedIndex else { return }
        guard self.isLoading.value == false else { return }
        
        self.isLoading.accept(true)
        self.syncCanSave()
        
        self.saveTodayEmotionUseCase.execute(
            emotions: self.items,
            selectedIndex: selectedIndex,
            caption: self.caption
        ) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading.accept(false)
                self.syncCanSave()
                
                switch result {
                case .success(let data):
                    self.saveSucceeded.accept(data)
                case .failure(let error):
                    self.saveFailed.accept(error)
                }
            }
        }
    }
    
    private func syncCanSave() {
        self.canSaveRelay.accept(self.selectedIndex != nil && self.isLoading.value == false)
    }
}
