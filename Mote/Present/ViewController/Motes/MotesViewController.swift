//
//  MotesViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/16/26.
//

import UIKit

final class MotesViewController: UIViewController {
    let viewModel: MotesViewModel
    
    init(viewModel: MotesViewModel) {
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
        self.navigationItem.title = "Motes"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
}
