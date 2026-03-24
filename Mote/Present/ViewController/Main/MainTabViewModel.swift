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
        fetchMoteSizeUseCase: FetchMoteSizeUseCase,
        fetchGravityOptionUseCase: FetchGravityOptionUseCase,
        fetchAppearanceThemeUseCase: FetchAppearanceThemeUseCase,
        updateAppearanceThemeUseCase: UpdateAppearanceThemeUseCase,
        firestore: Firestore,
        uidProvider: CurrentUserUIDProviding = ProfileSession.shared
    ) {
        let todayEmotionRepository = EmotionRepositoryImpl(firestore: firestore)
        let saveTodayEmotionUseCase = SaveTodayEmotionUseCase(
            todayEmotionRepository: todayEmotionRepository,
            uidProvider: uidProvider
        )
        
        let observeTodayEmotionUseCase = ObserveTodayEmotionUseCase(
            todayEmotionRepository: todayEmotionRepository,
            uidProvider: uidProvider
        )
        
        let fetchRecentEmotionsUseCase = FetchRecentEmotionsUseCase(
            todayEmotionRepository: todayEmotionRepository,
            uidProvider: uidProvider
        )
        
        self.todayViewModel = TodayViewModel(
            saveTodayEmotionUseCase: saveTodayEmotionUseCase,
            observeTodayEmotionUseCase: observeTodayEmotionUseCase
        )
        
        self.driftViewModel = DriftViewModel(
            fetchRecentEmotionsUseCase: fetchRecentEmotionsUseCase,
            fetchMoteSizeUseCase: fetchMoteSizeUseCase,
            fetchGravityOptionUseCase: fetchGravityOptionUseCase
        )
        self.spaceViewModel = SpaceViewModel(
            signOutUseCase: signOutUseCase,
            fetchAppearanceThemeUseCase: fetchAppearanceThemeUseCase,
            updateAppearanceThemeUseCase: updateAppearanceThemeUseCase
        )
    }
}
