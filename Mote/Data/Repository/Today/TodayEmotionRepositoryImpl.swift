//
//  TodayEmotionRepositoryImpl.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation
import FirebaseFirestore

final class TodayEmotionRepositoryImpl: TodayEmotionRepository {
    private let firestore: Firestore
    
    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }
    
    @discardableResult
    func observeTodayEmotion(
        uid: String,
        dateKey: String,
        onChange: @escaping (Result<EmotionRecord?, Error>) -> Void
    ) -> (() -> Void) {
        let documentRef = self.firestore
            .collection("users")
            .document(uid)
            .collection("dailyEmotions")
            .document(dateKey)
        
        let listener = documentRef.addSnapshotListener { snapshot, error in
            if let error {
                onChange(.failure(error))
                return
            }
            
            guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                onChange(.success(nil))
                return
            }
            
            let emotion = data["emotion"] as? String ?? ""
            let caption = data["caption"] as? String
            onChange(.success(EmotionRecord(emotion: emotion, caption: caption)))
        }
        
        return {
            listener.remove()
        }
    }
    
    func saveTodayEmotion(
        uid: String,
        emotion: String,
        caption: String?,
        dateKey: String,
        yearMonth: String,
        day: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let documentRef = self.firestore
            .collection("users")
            .document(uid)
            .collection("dailyEmotions")
            .document(dateKey)
        
        documentRef.getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            var payload: [String: Any] = [
                "emotion": emotion,
                "yearMonth": yearMonth,
                "day": day,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            payload["caption"] = caption ?? ""
            
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
}
