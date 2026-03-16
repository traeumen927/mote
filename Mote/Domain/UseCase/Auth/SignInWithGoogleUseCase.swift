//
//  SignInWithGoogleUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import FirebaseAuth

final class SignInWithGoogleUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    @MainActor
    func execute(completion: @escaping (Result<User, Error>) -> Void) {
        self.authRepository.signInWithGoogle(completion: completion)
    }
}
