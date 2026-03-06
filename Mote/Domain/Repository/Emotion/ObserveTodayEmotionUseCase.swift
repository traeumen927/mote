//
//  ObserveTodayEmotionUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation

final class ObserveTodayEmotionUseCase {
    
    enum ObserveTodayEmotionError: Error {
        case unauthenticated
    }
    
    private let todayEmotionRepository: EmotionRepository
    private let uidProvider: CurrentUserUIDProviding
    private let calendar: Calendar
    private var removeObserver: (() -> Void)?
    
    init(
        todayEmotionRepository: EmotionRepository,
        uidProvider: CurrentUserUIDProviding = FirebaseAuthSession.shared,
        calendar: Calendar = .current
    ) {
        self.todayEmotionRepository = todayEmotionRepository
        self.uidProvider = uidProvider
        self.calendar = calendar
    }
    
    func execute(date: Date = Date(), completion: @escaping (Result<EmotionRecord?, Error>) -> Void) {
        guard let uid = self.uidProvider.currentUID else {
            completion(.failure(ObserveTodayEmotionError.unauthenticated))
            return
        }
        
        let dateKey = self.format(date, format: "yyyy-MM-dd")
        
        self.removeObserver?()
        self.removeObserver = self.todayEmotionRepository.observeTodayEmotion(
            request: ObserveTodayEmotionRequest(
                uid: uid,
                dateKey: dateKey
            )
        ) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func stop() {
        self.removeObserver?()
        self.removeObserver = nil
    }
    
    deinit {
        self.stop()
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
