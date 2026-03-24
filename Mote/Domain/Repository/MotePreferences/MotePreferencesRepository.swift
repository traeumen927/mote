//
//  MotePreferencesRepository.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import Foundation

protocol MotePreferencesRepository {
    func fetchMoteSize() -> MoteSizeOption
    func updateMoteSize(_ size: MoteSizeOption)
    
    func fetchAppearanceTheme() -> AppearanceThemeOption
    func updateAppearanceTheme(_ theme: AppearanceThemeOption)
    
    func fetchGravityOption() -> GravityOption
    func updateGravityOption(_ gravityOption: GravityOption)
    
    func fetchBounceOption() -> BounceOption
    func updateBounceOption(_ bounceOption: BounceOption)
}
