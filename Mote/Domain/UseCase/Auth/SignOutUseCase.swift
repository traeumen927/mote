//
//  SignOutUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation

final class SignOutUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute() throws {
        try self.authRepository.signOut()
    }
}
