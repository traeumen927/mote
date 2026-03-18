//
//  SpaceViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation
import RxSwift
import RxCocoa

final class SpaceViewModel {
    
    private let signOutUseCase: SignOutUseCase
    private let updateAppearanceThemeUseCase: UpdateAppearanceThemeUseCase
    
    let appearanceTheme: BehaviorRelay<AppearanceThemeOption>
    
    init(
        signOutUseCase: SignOutUseCase,
        fetchAppearanceThemeUseCase: FetchAppearanceThemeUseCase,
        updateAppearanceThemeUseCase: UpdateAppearanceThemeUseCase
    ) {
        self.signOutUseCase = signOutUseCase
        self.updateAppearanceThemeUseCase = updateAppearanceThemeUseCase
        
        let initialAppearanceTheme = fetchAppearanceThemeUseCase.execute()
        self.appearanceTheme = BehaviorRelay(value: initialAppearanceTheme)
    }
    
    func signOut() throws {
        try self.signOutUseCase.execute()
    }
    
    func updateAppearanceTheme(_ theme: AppearanceThemeOption) {
        self.updateAppearanceThemeUseCase.execute(theme)
        self.appearanceTheme.accept(theme)
    }
}
