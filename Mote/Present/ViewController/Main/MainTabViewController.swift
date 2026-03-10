//
//  MainTabViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit

final class MainTabViewController: UITabBarController {
    
    private let viewModel: MainTabViewModel
    
    init(viewModel: MainTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabs()
    }
    
    private func setupTabs() {
        
        self.tabBar.tintColor = SemanticColor.iconTab.uiColor
        
        let todayViewController = TodayViewController(viewModel: viewModel.todayViewModel)
        todayViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "face.smiling"), selectedImage: UIImage(systemName: "face.smiling"))
        
        let driftViewController = DriftViewController(viewModel: viewModel.driftViewModel)
        driftViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "circle.dotted"), selectedImage: UIImage(systemName: "circle.dotted"))
        
        let spaceViewController = SpaceViewController(viewModel: viewModel.spaceViewModel)
        spaceViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "square.grid.2x2"), selectedImage: UIImage(systemName: "square.grid.2x2"))
        
        self.setViewControllers([
            UINavigationController(rootViewController: todayViewController),
            UINavigationController(rootViewController: driftViewController),
            UINavigationController(rootViewController: spaceViewController)
        ], animated: false)
    }
}
