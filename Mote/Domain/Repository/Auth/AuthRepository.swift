//
//  AuthRepository.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import FirebaseAuth

protocol AuthRepository {
    @MainActor
    func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void)
    
    func signOut() throws
    
    func addAuthStateListener(_ handler: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle
    
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle)
}
