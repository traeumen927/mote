//
//  ProfileViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/16/26.
//

import UIKit

final class ProfileViewController: UIViewController {
    let viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
    }
    
    private func setupLayout() {
        self.navigationItem.title = ProfileSession.shared.currentProfile?.username ?? "User"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
}
