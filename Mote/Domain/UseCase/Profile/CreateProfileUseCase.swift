//
//  CreateProfileUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation

final class CreateProfileUseCase {
    enum CreateProfileError: Error {
        case unauthenticated
        case emptyUsername
    }
    
    private let profileRepository: ProfileRepository
    private let uidProvider: CurrentUserUIDProviding
    
    init(
        profileRepository: ProfileRepository,
        uidProvider: CurrentUserUIDProviding = FirebaseAuthSession.shared
    ) {
        self.profileRepository = profileRepository
        self.uidProvider = uidProvider
    }
    
    func execute(
        username: String,
        date: Date = Date(),
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedUsername.isEmpty == false else {
            completion(.failure(CreateProfileError.emptyUsername))
            return
        }
        
        guard let uid = self.uidProvider.currentUID else {
            completion(.failure(CreateProfileError.unauthenticated))
            return
        }
        
        self.profileRepository.createProfile(
            request: CreateProfileRequest(
                uid: uid,
                username: normalizedUsername,
                date: date
            ),
            completion: completion
        )
    }
}
