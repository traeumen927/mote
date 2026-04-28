//
//  HistoryViewModel.swift
//  Mote
//
//  Created by 홍정연 on 4/28/26.
//

import Foundation

final class HistoryViewModel {
    struct Item {
        let dateKey: String
        let emotion: String
        let caption: String
        let isHidden: Bool
        let createdAt: Date?
    }
    
    struct ViewState {
        let items: [Item]
        let isLoading: Bool
        let isLoadingMore: Bool
        let canLoadMore: Bool
        let errorMessage: String?
    }
    
    var onStateChange: ((ViewState) -> Void)?
    
    private let fetchRecentEmotionsUseCase: FetchRecentEmotionsUseCase
    private let emotionRepository: EmotionRepository
    private let uidProvider: CurrentUserUIDProviding
    private let pageSize: Int
    
    private var items: [Item] = []
    private var currentLimit: Int = 0
    private var canLoadMore: Bool = true
    private var isLoading: Bool = false
    
    init(
        fetchRecentEmotionsUseCase: FetchRecentEmotionsUseCase,
        emotionRepository: EmotionRepository,
        uidProvider: CurrentUserUIDProviding = ProfileSession.shared,
        pageSize: Int = 20
    ) {
        self.fetchRecentEmotionsUseCase = fetchRecentEmotionsUseCase
        self.emotionRepository = emotionRepository
        self.uidProvider = uidProvider
        self.pageSize = pageSize
    }
    
    func loadInitial() {
        guard self.isLoading == false else { return }
        self.currentLimit = self.pageSize
        self.fetch(limit: self.currentLimit, isLoadingMore: false)
    }
    
    func loadMoreIfNeeded() {
        guard self.isLoading == false, self.canLoadMore else { return }
        self.currentLimit += self.pageSize
        self.fetch(limit: self.currentLimit, isLoadingMore: true)
    }
    
    func updateHidden(dateKey: String, isHidden: Bool) {
        guard let uid = self.uidProvider.currentUID,
              let index = self.items.firstIndex(where: { $0.dateKey == dateKey }) else {
            return
        }
        
        let currentItem = self.items[index]
        let request = SaveTodayEmotionRequest(
            uid: uid,
            emotion: currentItem.emotion,
            caption: currentItem.caption,
            isHidden: isHidden,
            dateKey: dateKey,
            yearMonth: String(dateKey.prefix(7)),
            day: Int(dateKey.suffix(2)) ?? 1
        )
        
        self.emotionRepository.saveTodayEmotion(request: request) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.items[index] = Item(
                    dateKey: currentItem.dateKey,
                    emotion: currentItem.emotion,
                    caption: currentItem.caption,
                    isHidden: isHidden,
                    createdAt: currentItem.createdAt
                )
                self.emit(errorMessage: nil)
            case .failure(let error):
                self.emit(errorMessage: error.localizedDescription)
            }
        }
    }
    
    private func fetch(limit: Int, isLoadingMore: Bool) {
        self.isLoading = true
        self.emit(isLoading: true, isLoadingMore: isLoadingMore, errorMessage: nil)
        
        self.fetchRecentEmotionsUseCase.execute(limit: limit, includeHidden: true) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let records):
                let sorted = records.sorted {
                    let leftDate = $0.createdAt ?? .distantPast
                    let rightDate = $1.createdAt ?? .distantPast
                    
                    if leftDate == rightDate {
                        return $0.dateKey < $1.dateKey
                    }
                    return leftDate < rightDate
                }
                
                self.items = sorted.map {
                    Item(
                        dateKey: $0.dateKey,
                        emotion: $0.emotion,
                        caption: $0.caption,
                        isHidden: $0.isHidden,
                        createdAt: $0.createdAt
                    )
                }
                self.canLoadMore = records.count >= limit
                self.emit(isLoading: false, isLoadingMore: false, errorMessage: nil)
            case .failure(let error):
                self.emit(isLoading: false, isLoadingMore: false, errorMessage: error.localizedDescription)
            }
        }
    }
    
    private func emit(
        isLoading: Bool? = nil,
        isLoadingMore: Bool? = nil,
        errorMessage: String?
    ) {
        self.onStateChange?(
            ViewState(
                items: self.items,
                isLoading: isLoading ?? self.isLoading,
                isLoadingMore: isLoadingMore ?? false,
                canLoadMore: self.canLoadMore,
                errorMessage: errorMessage
            )
        )
    }
}
