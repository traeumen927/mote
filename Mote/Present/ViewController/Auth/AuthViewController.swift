//
//  AuthViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit

final class AuthViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLayout()
    }
    
    private func setLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
    }
}
