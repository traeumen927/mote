//
//  SpaceViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation

final class SpaceViewModel {
    
    private let signOutUseCase: SignOutUseCase
    private let fetchAppearanceThemeUseCase: FetchAppearanceThemeUseCase
    private let updateAppearanceThemeUseCase: UpdateAppearanceThemeUseCase
    
    init(
        signOutUseCase: SignOutUseCase,
        fetchAppearanceThemeUseCase: FetchAppearanceThemeUseCase,
        updateAppearanceThemeUseCase: UpdateAppearanceThemeUseCase
    ) {
        self.signOutUseCase = signOutUseCase
        self.fetchAppearanceThemeUseCase = fetchAppearanceThemeUseCase
        self.updateAppearanceThemeUseCase = updateAppearanceThemeUseCase
    }
    
    func signOut() throws {
        try self.signOutUseCase.execute()
    }
    
    func fetchAppearanceTheme() -> AppearanceThemeOption {
        self.fetchAppearanceThemeUseCase.execute()
    }
    
    func updateAppearanceTheme(_ theme: AppearanceThemeOption) {
        self.updateAppearanceThemeUseCase.execute(theme)
    }
}
