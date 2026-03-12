//
//  ProfileRepositoryImpl.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation
import FirebaseFirestore

final class ProfileRepositoryImpl: ProfileRepository {
    
    enum ProfileRepositoryError: Error {
        case duplicatedUsername
    }
    
    private let firestore: Firestore
    
    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }
    
    func createProfile(
        request: CreateProfileRequest,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let normalizedUsername = request.username.lowercased()
        let profileRef = self.firestore
            .collection("users")
            .document(request.uid)
            .collection("profile")
            .document("current")
        
        let usernameRef = self.firestore
            .collection("usernames")
            .document(normalizedUsername)
        
        self.firestore.runTransaction({ transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(profileRef)
                let usernameSnapshot = try transaction.getDocument(usernameRef)
                
                if let usernameData = usernameSnapshot.data(),
                   let ownerUID = usernameData["uid"] as? String,
                   ownerUID != request.uid {
                    errorPointer?.pointee = ProfileRepositoryError.duplicatedUsername as NSError
                    return nil
                }
                
                let existingCreateAt = (snapshot.data()?["createAt"] as? Timestamp)?.dateValue()
                let createAt = existingCreateAt ?? request.date
                let lastActiveAt = request.date
                
                let profilePayload: [String: Any] = [
                    "uid": request.uid,
                    "username": normalizedUsername,
                    "createAt": createAt,
                    "lastActiveAt": lastActiveAt
                ]
                
                let usernamePayload: [String: Any] = [
                    "uid": request.uid,
                    "username": normalizedUsername,
                    "createAt": createAt,
                    "lastActiveAt": lastActiveAt
                ]
                
                transaction.setData(profilePayload, forDocument: profileRef, merge: true)
                transaction.setData(usernamePayload, forDocument: usernameRef)
                
                return profilePayload
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }) { payload, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let payload = payload as? [String: Any] else {
                completion(.failure(ProfileRepositoryError.duplicatedUsername))
                return
            }
            completion(.success(ProfileDTO(uid: request.uid, data: payload).toDomain()))
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
    
    func isUsernameDuplicated(
        request: CheckUsernameDuplicateRequest,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let username = request.username.lowercased()
        
        self.firestore.collection("usernames")
            .document(username)
            .getDocument { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(snapshot?.exists == true))
            }
    }
}
