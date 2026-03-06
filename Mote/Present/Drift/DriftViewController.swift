//
//  DriftViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit

final class DriftViewController: UIViewController {
    
    private let viewModel: DriftViewModel
    
    init(viewModel: DriftViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.bind()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
    
    private func bind() {
        self.viewModel.fetchRecentEmotions()
    }
}
