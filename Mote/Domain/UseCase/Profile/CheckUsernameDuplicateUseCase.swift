//
//  CheckUsernameDuplicateUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/12/26.
//

import Foundation

final class CheckUsernameDuplicateUseCase {
    enum CheckUsernameDuplicateError: Error {
        case emptyUsername
    }

    private let profileRepository: ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    func execute(
        username: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedUsername.isEmpty == false else {
            completion(.failure(CheckUsernameDuplicateError.emptyUsername))
            return
        }

        self.profileRepository.isUsernameDuplicated(
            request: CheckUsernameDuplicateRequest(username: normalizedUsername),
            completion: completion
        )
    }
}
