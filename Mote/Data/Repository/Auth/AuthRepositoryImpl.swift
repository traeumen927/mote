//
//  AuthRepositoryImpl.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation
import FirebaseAuth

final class AuthRepositoryImpl: AuthRepository {
    
    private let googleAuthService: GoogleAuthServicing
    
    init(googleAuthService: GoogleAuthServicing) {
        self.googleAuthService = googleAuthService
    }
    
    @MainActor
    func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        self.googleAuthService.signIn(completion: completion)
    }
    
    func signOut() throws {
        try self.googleAuthService.signOut()
    }
    
    func addAuthStateListener(_ handler: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        self.googleAuthService.addAuthStateListener(handler)
    }
    
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        self.googleAuthService.removeAuthStateListener(handle)
    }
}
