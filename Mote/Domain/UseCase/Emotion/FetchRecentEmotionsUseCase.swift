//
//  FetchRecentEmotionsUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/6/26.
//

import Foundation

final class FetchRecentEmotionsUseCase {
    
    enum FetchRecentEmotionsError: Error {
        case unauthenticated
    }
    
    private let todayEmotionRepository: EmotionRepository
    private let uidProvider: CurrentUserUIDProviding
    
    init(
        todayEmotionRepository: EmotionRepository,
        uidProvider: CurrentUserUIDProviding = ProfileSession.shared
    ) {
        self.todayEmotionRepository = todayEmotionRepository
        self.uidProvider = uidProvider
    }
    
    func execute(limit: Int, completion: @escaping (Result<[EmotionRecord], Error>) -> Void) {
        guard let uid = self.uidProvider.currentUID else {
            completion(.failure(FetchRecentEmotionsError.unauthenticated))
            return
        }
        
        let normalizedLimit = max(0, limit)
        
        self.todayEmotionRepository.fetchRecentEmotions(
            request: FetchRecentEmotionsRequest(uid: uid, limit: normalizedLimit)
        ) { result in
            switch result {
            case .success(let emotionRecords):
                completion(.success(emotionRecords))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
