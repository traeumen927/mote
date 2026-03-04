//
//  MainTabViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation
import FirebaseFirestore

final class MainTabViewModel {
    let todayViewModel: TodayViewModel
    let driftViewModel: DriftViewModel
    let spaceViewModel: SpaceViewModel
    
    init(
        signOutUseCase: SignOutUseCase,
        firestore: Firestore
    ) {
        let todayEmotionRepository = TodayEmotionRepositoryImpl(firestore: firestore)
        let saveTodayEmotionUseCase = SaveTodayEmotionUseCase(todayEmotionRepository: todayEmotionRepository)
        
        self.todayViewModel = TodayViewModel(saveTodayEmotionUseCase: saveTodayEmotionUseCase)
        self.driftViewModel = DriftViewModel()
        self.spaceViewModel = SpaceViewModel(signOutUseCase: signOutUseCase)
    }
}
