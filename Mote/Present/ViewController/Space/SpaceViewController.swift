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
    
    weak var coordinator: SpaceCoordinating?
    
    private enum Row {
        case profile
        case motes
        case appearance
        case logout
    }
    
    private let sections: [[Row]] = [
        [.profile],
        [.motes, .appearance],
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
        config.textProperties.font = Typography.bodyLarge
        config.textProperties.color = SemanticColor.textPrimary.uiColor
        config.secondaryTextProperties.color = SemanticColor.textSecondary.uiColor
        cell.accessoryType = .none
        cell.selectionStyle = .default
        
        switch row {
        case .profile:
            config.text = ProfileSession.shared.currentProfile?.username ?? "User"
            cell.accessoryType = .disclosureIndicator
            
        case .motes:
            config.text = "Motes"
            cell.accessoryType = .disclosureIndicator
            
        case .appearance:
            config.text = "Appearance"
            cell.accessoryType = .disclosureIndicator
            
        case .logout:
            config.text = "Sign Out"
            config.textProperties.color = SemanticColor.accentStrong.uiColor
            config.textProperties.alignment = .center
        }
        
        cell.contentConfiguration = config
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
            self.coordinator?.showProfile()
            
        case .motes:
            self.coordinator?.showMotes()
            
        case .appearance:
            return
            
        case .logout:
            self.handleLogout()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 2 else { return nil }
        return "You will be signed out of this account."
    }
}
