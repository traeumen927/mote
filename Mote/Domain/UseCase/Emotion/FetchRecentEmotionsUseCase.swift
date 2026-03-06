//
//  FetchRecentEmotionsUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/6/26.
//

import Foundation
import FirebaseAuth

final class FetchRecentEmotionsUseCase {

    enum FetchRecentEmotionsError: Error {
        case unauthenticated
    }

    private let todayEmotionRepository: TodayEmotionRepository
    private let auth: Auth

    init(
        todayEmotionRepository: TodayEmotionRepository,
        auth: Auth = .auth()
    ) {
        self.todayEmotionRepository = todayEmotionRepository
        self.auth = auth
    }

    func execute(limit: Int, completion: @escaping (Result<[EmotionRecord], Error>) -> Void) {
        guard let uid = self.auth.currentUser?.uid else {
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
