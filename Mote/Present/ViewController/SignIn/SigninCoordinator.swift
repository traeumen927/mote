//
//  SigninCoordinator.swift
//  Mote
//
//  Created by 홍정연 on 3/12/26.
//

import UIKit

final class SignInCoordinator {
    private let createProfileUseCase: CreateProfileUseCase
    private let fetchProfileUseCase: FetchProfileUseCase
    private let signOutUseCase: SignOutUseCase

    var onSignInFlowCompleted: (() -> Void)?

    init(
        createProfileUseCase: CreateProfileUseCase,
        fetchProfileUseCase: FetchProfileUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.createProfileUseCase = createProfileUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.signOutUseCase = signOutUseCase
    }

    func start() -> UIViewController {
        let viewModel = SignInViewModel(
            createProfileUseCase: self.createProfileUseCase,
            fetchProfileUseCase: self.fetchProfileUseCase,
            signOutUseCase: self.signOutUseCase
        )
        let signInViewController = SignInViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: signInViewController)

        viewModel.onProfileCreated = { [weak self, weak navigationController] profile in
            self?.showWelcome(profile: profile, in: navigationController)
        }

        return navigationController
    }

    private func showWelcome(profile: Profile, in navigationController: UINavigationController?) {
        let welcomeViewModel = WelcomeViewModel(profile: profile)
        welcomeViewModel.onConfirm = { [weak self] in
            self?.onSignInFlowCompleted?()
        }

        let welcomeViewController = WelcomeViewController(viewModel: welcomeViewModel)
        navigationController?.pushViewController(welcomeViewController, animated: true)
    }
}
