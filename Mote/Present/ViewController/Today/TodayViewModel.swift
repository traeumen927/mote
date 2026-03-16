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
    
    private let captionMaxLength: Int
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let saveSucceeded = PublishRelay<SaveTodayEmotionUseCase.ResultData>()
    let saveFailed = PublishRelay<Error>()
    let initialStateLoaded = PublishRelay<TodayInitialState>()
    let resetForNewDay = PublishRelay<Void>()
    
    private let canSaveRelay = BehaviorRelay<Bool>(value: false)
    private let captionCountTextRelay = BehaviorRelay<String>(value: "")
    private let titleTextRelay = BehaviorRelay<String>(value: "")
    
    var canSave: Driver<Bool> {
        self.canSaveRelay.asDriver()
    }
    
    var captionCountText: Driver<String> {
        self.captionCountTextRelay.asDriver()
    }
    
    var titleText: Driver<String> {
        self.titleTextRelay.asDriver()
    }
    
    var configuredCaptionMaxLength: Int {
        self.captionMaxLength
    }
    
    private var selectedIndex: Int?
    private var caption: String?
    
    private var latestSavedEmotion: String?
    private var latestSavedCaption: String?
    
    private let saveTodayEmotionUseCase: SaveTodayEmotionUseCase
    
    private let observeTodayEmotionUseCase: ObserveTodayEmotionUseCase
    private let calendar: Calendar
    private var activeDate: Date
    
    init(
        saveTodayEmotionUseCase: SaveTodayEmotionUseCase,
        observeTodayEmotionUseCase: ObserveTodayEmotionUseCase,
        calendar: Calendar = .current,
        captionMaxLength: Int = 20
    ) {
        self.saveTodayEmotionUseCase = saveTodayEmotionUseCase
        self.observeTodayEmotionUseCase = observeTodayEmotionUseCase
        self.calendar = calendar
        self.captionMaxLength = captionMaxLength
        self.activeDate = Date()
        self.titleTextRelay.accept(Self.formatTitle(self.activeDate, calendar: calendar))
        self.syncCaptionCount()
    }
    
    deinit {
        self.observeTodayEmotionUseCase.stop()
    }
    
    func observeTodayEmotion() {
        self.observeForActiveDate()
    }
    
    func refreshForTabReturnIfNeeded() {
        let now = Date()
        guard self.calendar.isDate(now, inSameDayAs: self.activeDate) == false else { return }
        
        self.activeDate = now
        self.titleTextRelay.accept(Self.formatTitle(now, calendar: self.calendar))
        self.resetCurrentState()
        self.resetForNewDay.accept(())
        self.observeForActiveDate()
    }
    
    func selectEmotion(at index: Int) {
        self.selectedIndex = index
        self.syncCanSave()
    }
    
    @discardableResult
    func updateCaption(_ caption: String?) -> String? {
        let sanitizedCaption = self.sanitizedCaption(caption)
        self.caption = sanitizedCaption
        self.syncCaptionCount()
        self.syncCanSave()
        return sanitizedCaption
    }
    
    func saveTodayEmotion() {
        guard let selectedIndex else { return }
        guard self.isLoading.value == false else { return }
        
        self.isLoading.accept(true)
        self.syncCanSave()
        
        self.saveTodayEmotionUseCase.execute(
            emotions: self.items,
            selectedIndex: selectedIndex,
            caption: self.caption,
            date: self.activeDate
        ) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading.accept(false)
                
                switch result {
                case .success(let data):
                    self.latestSavedEmotion = data.emotion
                    self.latestSavedCaption = self.sanitizedCaption(data.caption)
                    self.saveSucceeded.accept(data)
                case .failure(let error):
                    self.saveFailed.accept(error)
                }
                self.syncCanSave()
            }
        }
    }
    
    private func observeForActiveDate() {
        self.titleTextRelay.accept(Self.formatTitle(self.activeDate, calendar: self.calendar))
        self.observeTodayEmotionUseCase.execute(date: self.activeDate) { [weak self] result in
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
    
    private func resetCurrentState() {
        self.selectedIndex = nil
        self.caption = nil
        self.latestSavedEmotion = nil
        self.latestSavedCaption = nil
        self.syncCaptionCount()
        self.syncCanSave()
    }
    
    private func applyLatestSavedData(_ data: EmotionRecord?) {
        self.latestSavedEmotion = data?.emotion
        self.latestSavedCaption = self.sanitizedCaption(data?.caption)
        
        guard let data,
              let selectedIndex = EmotionItem.index(matching: data.emotion) else {
            self.selectedIndex = nil
            self.caption = nil
            self.syncCaptionCount()
            self.syncCanSave()
            return
        }
        
        self.selectedIndex = selectedIndex
        let caption = self.sanitizedCaption(data.caption)
        self.caption = caption
        self.initialStateLoaded.accept(TodayInitialState(selectedIndex: selectedIndex, caption: caption))
        self.syncCaptionCount()
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
    
    private func syncCaptionCount() {
        let currentCount = self.caption?.count ?? 0
        guard self.captionMaxLength > 0 else {
            self.captionCountTextRelay.accept("")
            return
        }
        self.captionCountTextRelay.accept("(\(currentCount)/\(self.captionMaxLength))")
    }
    
    private func sanitizedCaption(_ caption: String?) -> String? {
        guard let caption else { return nil }
        guard self.captionMaxLength > 0 else { return caption }
        return String(caption.prefix(self.captionMaxLength))
    }
    
    private func normalize(_ caption: String?) -> String? {
        let value = caption?.trimmingCharacters(in: .whitespacesAndNewlines)
        return value?.isEmpty == true ? nil : value
    }
    
    private static func formatTitle(_ date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}
