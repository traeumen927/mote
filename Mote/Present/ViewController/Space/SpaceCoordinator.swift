//
//  SpaceCoordinator.swift
//  Mote
//
//  Created by 홍정연 on 3/16/26.
//

import UIKit

protocol SpaceCoordinating: AnyObject {
    func showProfile()
    func showMotes()
    func applyAppearanceTheme(_ theme: AppearanceThemeOption)
}

final class SpaceCoordinator: SpaceCoordinating {
    private let spaceViewModel: SpaceViewModel
    private weak var navigationController: UINavigationController?
    
    init(spaceViewModel: SpaceViewModel) {
        self.spaceViewModel = spaceViewModel
    }
    
    func start() -> UIViewController {
        let spaceViewController = SpaceViewController(viewModel: self.spaceViewModel)
        let navigationController = UINavigationController(rootViewController: spaceViewController)
        
        spaceViewController.coordinator = self
        self.navigationController = navigationController
        
        return navigationController
    }
    
    func showProfile() {
        let profileViewController = ProfileViewController(viewModel: ProfileViewModel())
        profileViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func showMotes() {
        let motePreferencesRepository = MotePreferencesRepositoryImpl(uidProvider: ProfileSession.shared)
        let fetchMoteSizeUseCase = FetchMoteSizeUseCase(motePreferencesRepository: motePreferencesRepository)
        let updateMoteSizeUseCase = UpdateMoteSizeUseCase(motePreferencesRepository: motePreferencesRepository)
        let motesViewController = MotesViewController(
            viewModel: MotesViewModel(
                fetchMoteSizeUseCase: fetchMoteSizeUseCase,
                updateMoteSizeUseCase: updateMoteSizeUseCase
            )
        )
        
        motesViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(motesViewController, animated: true)
    }
    
    func applyAppearanceTheme(_ theme: AppearanceThemeOption) {
        AppAppearance.apply(theme: theme, to: self.navigationController?.view.window)
    }
}
