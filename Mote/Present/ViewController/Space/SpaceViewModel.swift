//
//  SpaceViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation

final class SpaceViewModel {
    
    private let signOutUseCase: SignOutUseCase
    
    init(signOutUseCase: SignOutUseCase) {
        self.signOutUseCase = signOutUseCase
    }
    
    func signOut() throws {
        try self.signOutUseCase.execute()
    }
}
