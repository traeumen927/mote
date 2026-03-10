//
//  SignInViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import UIKit

final class SignInViewController: UIViewController {
    
    private var viewModel: SignInViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
    
    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
