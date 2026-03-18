//
//  SpaceViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SpaceViewController: UIViewController {
    
    private let viewModel: SpaceViewModel
    private let disposeBag = DisposeBag()
    
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var appearanceMenuInteraction = UIEditMenuInteraction(delegate: self)
    
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
        self.bind()
    }
    
    private func setupLayout() {
        self.navigationItem.title = "Space"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        self.view.addSubview(self.tableView)
        self.tableView.addInteraction(self.appearanceMenuInteraction)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        self.viewModel.appearanceTheme
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] theme in
                self?.coordinator?.applyAppearanceTheme(theme)
                self?.reloadAppearanceRow()
            }
            .disposed(by: self.disposeBag)
    }
    
    private func appearanceIndexPath() -> IndexPath {
        guard let section = self.sections.firstIndex(where: { $0.contains(.appearance) }),
              let row = self.sections[section].firstIndex(of: .appearance) else {
            return IndexPath(row: 1, section: 1)
        }
        
        return IndexPath(row: row, section: section)
    }
    
    private func reloadAppearanceRow() {
        let appearanceIndexPath = self.appearanceIndexPath()
        
        guard self.tableView.numberOfSections > appearanceIndexPath.section,
              self.tableView.numberOfRows(inSection: appearanceIndexPath.section) > appearanceIndexPath.row else {
            self.tableView.reloadData()
            return
        }
        self.tableView.reloadRows(at: [appearanceIndexPath], with: .none)
    }
    
    private func appearanceMenu() -> UIMenu {
        let actions = AppearanceThemeOption.allCases.map { theme in
            UIAction(
                title: theme.title,
                state: theme == self.viewModel.appearanceTheme.value ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.updateAppearanceTheme(theme)
            }
        }
        
        return UIMenu(title: "Appearance", options: .singleSelection, children: actions)
    }
    
    private func presentAppearanceMenu(at indexPath: IndexPath) {
        let cellRect = self.tableView.rectForRow(at: indexPath)
        let sourcePoint = CGPoint(x: cellRect.maxX, y: cellRect.midY)
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: sourcePoint)
        self.appearanceMenuInteraction.presentEditMenu(with: configuration)
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
        
        switch row {
        case .logout:
            let identifier = "defaultCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
            
            cell.backgroundColor = SemanticColor.bgGrouped.uiColor
            cell.selectionStyle = .default
            cell.accessoryType = .none
            
            cell.textLabel?.text = "Sign Out"
            cell.textLabel?.textColor = SemanticColor.accentStrong.uiColor
            cell.textLabel?.font = Typography.bodyLarge
            cell.textLabel?.textAlignment = .center
            
            cell.detailTextLabel?.text = nil
            
            return cell
            
        default:
            let identifier = "value1Cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            ?? UITableViewCell(style: .value1, reuseIdentifier: identifier)
            
            cell.backgroundColor = SemanticColor.bgGrouped.uiColor
            cell.selectionStyle = .default
            cell.accessoryType = .none
            
            cell.textLabel?.font = Typography.bodyLarge
            cell.textLabel?.textColor = SemanticColor.textPrimary.uiColor
            cell.textLabel?.textAlignment = .left
            
            cell.detailTextLabel?.font = Typography.body
            cell.detailTextLabel?.textColor = SemanticColor.textSecondary.uiColor
            cell.detailTextLabel?.text = nil
            
            switch row {
            case .profile:
                cell.textLabel?.text = ProfileSession.shared.currentProfile?.username ?? "User"
                cell.accessoryType = .disclosureIndicator
                
            case .motes:
                cell.textLabel?.text = "Motes"
                cell.accessoryType = .disclosureIndicator
                
            case .appearance:
                cell.textLabel?.text = "Appearance"
                cell.detailTextLabel?.text = self.viewModel.appearanceTheme.value.title
                cell.accessoryType = .disclosureIndicator
                
            case .logout:
                break
            }
            
            return cell
        }
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
            self.presentAppearanceMenu(at: indexPath)
            
        case .logout:
            self.handleLogout()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 2 else { return nil }
        return "You will be signed out of this account."
    }
}

extension SpaceViewController: UIEditMenuInteractionDelegate {
    
    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        return self.appearanceMenu()
    }
}
