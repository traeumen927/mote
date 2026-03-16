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
    
    private enum Section: Int, CaseIterable {
        case profile
        case account
        
        var title: String? {
            switch self {
            case .profile:
                return nil
            case .account:
                return nil
            }
        }
    }
    
    private enum Row {
        case profile
        case logout
        
        var title: String {
            switch self {
            case .profile:
                return "내 정보"
            case .logout:
                return "Sign Out"
            }
        }
        
        var iconName: String? {
            switch self {
            case .profile:
                return "person.circle"
            case .logout:
                return nil
            }
        }
    }
    
    private let sections: [[Row]] = [
        [.profile],
        [.logout]
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 16)
        tableView.rowHeight = 56
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
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
    }
    
    private func setupLayout() {
        self.navigationItem.title = "Space"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func handleLogout() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to leave this space?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            guard let self else { return }
            
            do {
                try self.viewModel.signOut()
            } catch {
                let errorAlert = UIAlertController(
                    title: "Couldn't log out",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(errorAlert, animated: true)
            }
        })
        
        self.present(alert, animated: true)
    }
}

extension SpaceViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let row = self.sections[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = row.title
        config.textProperties.font = .systemFont(ofSize: 17)
        
        switch row {
        case .profile:
            config.image = UIImage(systemName: row.iconName ?? "")
            config.imageProperties.tintColor = .systemGray
            config.textProperties.color = .label
            cell.accessoryType = .disclosureIndicator
            
        case .logout:
            config.textProperties.color = .systemRed
            cell.accessoryType = .none
        }
        
        cell.contentConfiguration = config
        cell.selectionStyle = .default
        cell.backgroundColor = SemanticColor.bgGrouped.uiColor
        
        return cell
    }
}

extension SpaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = self.sections[indexPath.section][indexPath.row]
        
        switch row {
        case .profile:
            print("프로필 화면으로 이동")
            
        case .logout:
            self.handleLogout()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        return "You will be signed out of this account."
    }
}
