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
    
    struct TodayInitialState {
        let selectedIndex: Int
        let caption: String?
    }
    
    let items = EmotionItem.allCases
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let saveSucceeded = PublishRelay<SaveTodayEmotionUseCase.ResultData>()
    let saveFailed = PublishRelay<Error>()
    let initialStateLoaded = PublishRelay<TodayInitialState>()
    
    private let canSaveRelay = BehaviorRelay<Bool>(value: false)
    var canSave: Driver<Bool> {
        self.canSaveRelay.asDriver()
    }
    
    private var selectedIndex: Int?
    private var caption: String?
    
    private var latestSavedEmotion: String?
    private var latestSavedCaption: String?
    
    private let saveTodayEmotionUseCase: SaveTodayEmotionUseCase
    
    private let observeTodayEmotionUseCase: ObserveTodayEmotionUseCase
    
    init(
        saveTodayEmotionUseCase: SaveTodayEmotionUseCase,
        observeTodayEmotionUseCase: ObserveTodayEmotionUseCase
    ) {
        self.saveTodayEmotionUseCase = saveTodayEmotionUseCase
        self.observeTodayEmotionUseCase = observeTodayEmotionUseCase
    }
    
    deinit {
        self.observeTodayEmotionUseCase.stop()
    }
    
    func observeTodayEmotion() {
        self.observeTodayEmotionUseCase.execute { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.applyLatestSavedData(data)
                case .failure(let error):
                    self.saveFailed.accept(error)
                }
            }
        }
    }
    
    func selectEmotion(at index: Int) {
        self.selectedIndex = index
        self.syncCanSave()
    }
    
    func updateCaption(_ caption: String?) {
        self.caption = caption
        self.syncCanSave()
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
                
                switch result {
                case .success(let data):
                    self.latestSavedEmotion = data.emotion
                    self.latestSavedCaption = data.caption
                    self.saveSucceeded.accept(data)
                case .failure(let error):
                    self.saveFailed.accept(error)
                }
                self.syncCanSave()
            }
        }
    }
    
    private func applyLatestSavedData(_ data: EmotionRecord?) {
        self.latestSavedEmotion = data?.emotion
        self.latestSavedCaption = data?.caption
        
        guard let data,
              let selectedIndex = EmotionItem.index(matching: data.emotion) else {
            self.syncCanSave()
            return
        }
        
        self.selectedIndex = selectedIndex
        self.caption = data.caption
        self.initialStateLoaded.accept(TodayInitialState(selectedIndex: selectedIndex, caption: data.caption))
        self.syncCanSave()
    }
    
    private func syncCanSave() {
        guard self.isLoading.value == false else {
            self.canSaveRelay.accept(false)
            return
        }
        
        guard let selectedIndex else {
            self.canSaveRelay.accept(false)
            return
        }
        
        let selectedEmotion = self.items[selectedIndex].rawValue
        let normalizedCurrentCaption = self.normalize(self.caption)
        let normalizedLatestCaption = self.normalize(self.latestSavedCaption)
        
        let hasChanges = selectedEmotion != self.latestSavedEmotion || normalizedCurrentCaption != normalizedLatestCaption
        self.canSaveRelay.accept(hasChanges)
    }
    
    private func normalize(_ caption: String?) -> String? {
        let value = caption?.trimmingCharacters(in: .whitespacesAndNewlines)
        return value?.isEmpty == true ? nil : value
    }
}
