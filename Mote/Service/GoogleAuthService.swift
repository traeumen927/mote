//
//  GoogleAuthService.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

protocol GoogleAuthServicing {
    typealias AuthStateHandler = (User?) -> Void

    @MainActor
    func signIn(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void)

    func signOut() throws

    func addAuthStateListener(_ handler: @escaping AuthStateHandler) -> AuthStateDidChangeListenerHandle

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle)
}

final class GoogleAuthService: GoogleAuthServicing {

    @MainActor
    func signIn(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            self.signInToFirebase(with: credential, completion: completion)
        }
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }

    func addAuthStateListener(_ handler: @escaping AuthStateHandler) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            handler(user)
        }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    private func signInToFirebase(with credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else { return }

            completion(.success(user))
        }
    }
}
