//
//  SignInViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation

final class SignInViewModel {
    var onProfileCreated: (() -> Void)?
    
    func didCreateProfile() {
        self.onProfileCreated?()
    }
}
