//
//  ProfileRepositoryImpl.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation
import FirebaseFirestore

final class ProfileRepositoryImpl: ProfileRepository {
    private let firestore: Firestore

    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }

    func createProfile(
        request: CreateProfileRequest,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let documentRef = self.firestore
            .collection("users")
            .document(request.uid)
            .collection("profile")
            .document("current")

        documentRef.getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            let existingCreateAt = (snapshot?.data()?["createAt"] as? Timestamp)?.dateValue()
            let createAt = existingCreateAt ?? request.date
            let lastActiveAt = request.date

            let payload: [String: Any] = [
                "uid": request.uid,
                "username": request.username,
                "createAt": createAt,
                "lastActiveAt": lastActiveAt
            ]

            documentRef.setData(payload, merge: true) { error in
                if let error {
                    completion(.failure(error))
                    return
                }

                completion(.success(ProfileDTO(uid: request.uid, data: payload).toDomain()))
            }
        }
    }

    func fetchProfile(
        request: FetchProfileRequest,
        completion: @escaping (Result<Profile?, Error>) -> Void
    ) {
        self.firestore
            .collection("users")
            .document(request.uid)
            .collection("profile")
            .document("current")
            .getDocument { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                    completion(.success(nil))
                    return
                }

                let profile = ProfileDTO(uid: request.uid, data: data).toDomain()
                completion(.success(profile))
            }
    }
}
