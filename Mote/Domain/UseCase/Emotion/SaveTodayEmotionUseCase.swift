//
//  SaveTodayEmotionUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation
import FirebaseAuth

final class SaveTodayEmotionUseCase {
    struct ResultData {
        let emotion: String
        let caption: String
        let dateKey: String
        let yearMonth: String
        let day: Int
    }
    
    enum SaveTodayEmotionError: Error {
        case invalidEmotionSelection
        case unauthenticated
    }
    
    private let todayEmotionRepository: TodayEmotionRepository
    private let auth: Auth
    private let calendar: Calendar
    
    init(
        todayEmotionRepository: TodayEmotionRepository,
        auth: Auth = .auth(),
        calendar: Calendar = .current
    ) {
        self.todayEmotionRepository = todayEmotionRepository
        self.auth = auth
        self.calendar = calendar
    }
    
    func execute(
        emotions: [EmotionItem],
        selectedIndex: Int,
        caption: String?,
        completion: @escaping (Result<ResultData, Error>) -> Void
    ) {
        guard emotions.indices.contains(selectedIndex) else {
            completion(.failure(SaveTodayEmotionError.invalidEmotionSelection))
            return
        }
        
        guard let uid = self.auth.currentUser?.uid else {
            completion(.failure(SaveTodayEmotionError.unauthenticated))
            return
        }
        
        let now = Date()
        let dateKey = self.format(now, format: "yyyy-MM-dd")
        let yearMonth = self.format(now, format: "yyyy-MM")
        let day = self.calendar.component(.day, from: now)
        let emotion = emotions[selectedIndex].rawValue
        let trimmedCaption = caption?.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedCaption = trimmedCaption ?? ""
        
        self.todayEmotionRepository.saveTodayEmotion(
            request: SaveTodayEmotionRequest(
                uid: uid,
                emotion: emotion,
                caption: normalizedCaption,
                dateKey: dateKey,
                yearMonth: yearMonth,
                day: day
            )
        ) { result in
            switch result {
            case .success:
                completion(.success(ResultData(
                    emotion: emotion,
                    caption: normalizedCaption,
                    dateKey: dateKey,
                    yearMonth: yearMonth,
                    day: day
                )))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func format(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = self.calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = self.calendar.timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
