//
//  FetchProfileUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation

final class FetchProfileUseCase {
    enum FetchProfileError: Error {
        case unauthenticated
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
    
    func execute(completion: @escaping (Result<Profile?, Error>) -> Void) {
        guard let uid = self.uidProvider.currentUID else {
            completion(.failure(FetchProfileError.unauthenticated))
            return
        }
        
        self.profileRepository.fetchProfile(
            request: FetchProfileRequest(uid: uid),
            completion: completion
        )
    }
}
