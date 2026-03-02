//
//  LoginViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation

final class LoginViewModel {
    private let signInWithGoogleUseCase: SignInWithGoogleUseCase

    init(signInWithGoogleUseCase: SignInWithGoogleUseCase) {
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
    }
}
