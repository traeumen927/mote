//
//  SpaceViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SnapKit

final class SpaceViewController: UIViewController {
    
    private let viewModel: SpaceViewModel
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(SemanticColor.textPrimary.uiColor, for: .normal)
        return button
    }()
    
    init(viewModel: SpaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.setupAction()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        self.view.addSubview(self.logoutButton)
        
        self.logoutButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupAction() {
        self.logoutButton.addTarget(self, action: #selector(self.didTapLogoutButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapLogoutButton() {
        do {
            try self.viewModel.signOut()
        } catch {
            let alert = UIAlertController(title: "로그아웃 실패", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}
