//
//  HistoryViewController.swift
//  Mote
//
//  Created by 홍정연 on 4/28/26.
//

import UIKit

final class HistoryViewController: UIViewController {
    let viewModel: HistoryViewModel
    
    init(viewModel: HistoryViewModel) {
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
        self.navigationItem.title = "History"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
}
