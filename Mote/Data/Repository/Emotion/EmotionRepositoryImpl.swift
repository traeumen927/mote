//
//  TodayEmotionRepositoryImpl.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation
import FirebaseFirestore

final class EmotionRepositoryImpl: EmotionRepository {
    private let firestore: Firestore
    
    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }
    
    @discardableResult
    func observeTodayEmotion(
        request: ObserveTodayEmotionRequest,
        onChange: @escaping (Result<EmotionRecord?, Error>) -> Void
    ) -> (() -> Void) {
        let documentRef = self.firestore
            .collection("users")
            .document(request.uid)
            .collection("dailyEmotions")
            .document(request.dateKey)
        
        let listener = documentRef.addSnapshotListener { snapshot, error in
            if let error {
                onChange(.failure(error))
                return
            }
            
            guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                onChange(.success(nil))
                return
            }
            
            let dto = EmotionRecordDTO(data: data, dateKey: request.dateKey)
            onChange(.success(dto.toDomain()))
        }
        
        return {
            listener.remove()
        }
    }
    
    func saveTodayEmotion(
        request: SaveTodayEmotionRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let documentRef = self.firestore
            .collection("users")
            .document(request.uid)
            .collection("dailyEmotions")
            .document(request.dateKey)
        
        documentRef.getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            var payload: [String: Any] = [
                "emotion": request.emotion,
                "yearMonth": request.yearMonth,
                "day": request.day,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            payload["caption"] = request.caption
            
            if snapshot?.exists != true {
                payload["createdAt"] = FieldValue.serverTimestamp()
            }
            
            documentRef.setData(payload, merge: true) { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(()))
            }
        }
    }
    
    func fetchRecentEmotions(
        request: FetchRecentEmotionsRequest,
        completion: @escaping (Result<[EmotionRecord], Error>) -> Void
    ) {
        self.firestore
            .collection("users")
            .document(request.uid)
            .collection("dailyEmotions")
            .order(by: "createdAt", descending: true)
            .limit(to: request.limit)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let records = documents.map { document in
                    EmotionRecordDTO(data: document.data(), dateKey: document.documentID).toDomain()
                }
                
                completion(.success(records))
            }
    }
}
