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
        let todayEmotionRepository = EmotionRepositoryImpl(firestore: firestore)
        let saveTodayEmotionUseCase = SaveTodayEmotionUseCase(todayEmotionRepository: todayEmotionRepository)
        
        let observeTodayEmotionUseCase = ObserveTodayEmotionUseCase(todayEmotionRepository: todayEmotionRepository)
        
        let fetchRecentEmotionsUseCase = FetchRecentEmotionsUseCase(todayEmotionRepository: todayEmotionRepository)
        
        self.todayViewModel = TodayViewModel(
            saveTodayEmotionUseCase: saveTodayEmotionUseCase,
            observeTodayEmotionUseCase: observeTodayEmotionUseCase
        )
        
        self.driftViewModel = DriftViewModel(fetchRecentEmotionsUseCase: fetchRecentEmotionsUseCase)
        self.spaceViewModel = SpaceViewModel(signOutUseCase: signOutUseCase)
    }
}
