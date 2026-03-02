//
//  MainTabViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation

final class MainTabViewModel {
    let todayViewModel: TodayViewModel
    let driftViewModel: DriftViewModel
    let spaceViewModel: SpaceViewModel
    
    init(signOutUseCase: SignOutUseCase) {
        self.todayViewModel = TodayViewModel()
        self.driftViewModel = DriftViewModel()
        self.spaceViewModel = SpaceViewModel(signOutUseCase: signOutUseCase)
    }
}
