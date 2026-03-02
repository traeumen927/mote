//
//  LoginViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SnapKit

final class LoginViewController: UIViewController {
    
    private let viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
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
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        let titleLabel = UILabel()
        titleLabel.text = "Press. Save. Let it drop."
        titleLabel.font = Typography.largeTitle
        titleLabel.textColor = SemanticColor.textPrimary.uiColor
        titleLabel.textAlignment = .center
        
        self.view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
