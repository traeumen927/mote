//
//  SignInWithGoogleUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import FirebaseAuth

final class SignInWithGoogleUseCase {
    private let googleAuthService: GoogleAuthServicing
    
    init(googleAuthService: GoogleAuthServicing) {
        self.googleAuthService = googleAuthService
    }
    
    @MainActor
    func execute(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        googleAuthService.signIn(presentingViewController: presentingViewController, completion: completion)
    }
}
