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
        let todayViewController = TodayViewController(viewModel: viewModel.todayViewModel)
        todayViewController.tabBarItem = UITabBarItem(title: "Today", image: UIImage(systemName: "sun.max"), selectedImage: UIImage(systemName: "sun.max.fill"))
        
        let driftViewController = DriftViewController(viewModel: viewModel.driftViewModel)
        driftViewController.tabBarItem = UITabBarItem(title: "Drift", image: UIImage(systemName: "wind"), selectedImage: UIImage(systemName: "wind"))
        
        let spaceViewController = SpaceViewController(viewModel: viewModel.spaceViewModel)
        spaceViewController.tabBarItem = UITabBarItem(title: "Space", image: UIImage(systemName: "sparkles"), selectedImage: UIImage(systemName: "sparkles"))
        
        self.setViewControllers([
            UINavigationController(rootViewController: todayViewController),
            UINavigationController(rootViewController: driftViewController),
            UINavigationController(rootViewController: spaceViewController)
        ], animated: false)
    }
}
