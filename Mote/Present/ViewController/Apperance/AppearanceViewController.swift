//
//  AppearanceViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/16/26.
//

import UIKit

final class AppearanceViewController: UIViewController {
    let viewModel: AppearanceViewModel
    
    init(viewModel: AppearanceViewModel) {
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
        self.navigationItem.title = "Appearance"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
}
