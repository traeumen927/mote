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
    func showAppearance()
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
        let motesViewController = MotesViewController(viewModel: MotesViewModel())
        motesViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(motesViewController, animated: true)
    }

    func showAppearance() {
        let appearanceViewController = AppearanceViewController(viewModel: AppearanceViewModel())
        appearanceViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(appearanceViewController, animated: true)
    }
}
