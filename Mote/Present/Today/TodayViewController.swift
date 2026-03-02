//
//  TodayViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit

final class TodayViewController: UIViewController {
    
    private let viewModel: TodayViewModel
    
    init(viewModel: TodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
}
