//
//  ObserveTodayEmotionUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation
import FirebaseAuth

final class ObserveTodayEmotionUseCase {

    enum ObserveTodayEmotionError: Error {
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

    func execute(completion: @escaping (Result<EmotionRecord?, Error>) -> Void) {
        guard let uid = self.auth.currentUser?.uid else {
            completion(.failure(ObserveTodayEmotionError.unauthenticated))
            return
        }

        let dateKey = self.format(Date(), format: "yyyy-MM-dd")

        self.todayEmotionRepository.fetchTodayEmotion(
            uid: uid,
            dateKey: dateKey
        ) { result in
            switch result {
            case .success(let data):
                guard let data else {
                    completion(.success(nil))
                    return
                }
                completion(.success(EmotionRecord(emotion: data.emotion, caption: data.caption)))
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
