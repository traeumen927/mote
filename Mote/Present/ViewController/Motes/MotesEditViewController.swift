//
//  MotesEditViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MotesEditViewController: UIViewController {
    
    private let viewModel: MotesViewModel
    private let disposeBag = DisposeBag()
    
    private enum Row: Int, CaseIterable {
        case size
        case gravity
        case appearance3
        
        var title: String {
            switch self {
            case .size:
                return "Size"
            case .gravity:
                return "Gravity"
            case .appearance3:
                return "appearance3"
            }
        }
    }
    
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
    
    private lazy var sizeMenuInteraction = UIEditMenuInteraction(delegate: self)
    private lazy var gravityMenuInteraction = UIEditMenuInteraction(delegate: self)
    private var activeMenuRow: Row?
    
    init(viewModel: MotesViewModel) {
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
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        self.navigationItem.title = "Edit Motes"
        
        self.view.addSubview(self.tableView)
        self.tableView.addInteraction(self.sizeMenuInteraction)
        self.tableView.addInteraction(self.gravityMenuInteraction)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        self.viewModel.moteSizeOption
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.reloadRow(.size)
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.gravityOption
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.reloadRow(.gravity)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func indexPath(for row: Row) -> IndexPath {
        return IndexPath(row: row.rawValue, section: 0)
    }
    
    private func reloadRow(_ row: Row) {
        let indexPath = self.indexPath(for: row)
        
        guard self.tableView.numberOfSections > indexPath.section,
              self.tableView.numberOfRows(inSection: indexPath.section) > indexPath.row else {
            self.tableView.reloadData()
            return
        }
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    private func sizeMenu() -> UIMenu {
        let actions = MoteSizeOption.allCases.map { sizeOption in
            UIAction(
                title: sizeOption.title,
                state: sizeOption == self.viewModel.moteSizeOption.value ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.updateMoteSizeOption(sizeOption)
            }
        }
        
        return UIMenu(title: "Size", options: .singleSelection, children: actions)
    }
    
    private func gravityMenu() -> UIMenu {
        let actions = GravityOption.allCases.map { gravityOption in
            UIAction(
                title: gravityOption.title,
                state: gravityOption == self.viewModel.gravityOption.value ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.updateGravityOption(gravityOption)
            }
        }
        
        return UIMenu(title: "Gravity", options: .singleSelection, children: actions)
    }
    
    private func presentMenu(at indexPath: IndexPath, for row: Row) {
        let cellRect = self.tableView.rectForRow(at: indexPath)
        let sourcePoint = CGPoint(x: cellRect.maxX, y: cellRect.midY)
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: sourcePoint)
        self.activeMenuRow = row
        
        switch row {
        case .size:
            self.sizeMenuInteraction.presentEditMenu(with: configuration)
        case .gravity:
            self.gravityMenuInteraction.presentEditMenu(with: configuration)
        case .appearance3:
            break
        }
    }
}

extension MotesEditViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let identifier = "value1Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        ?? UITableViewCell(style: .value1, reuseIdentifier: identifier)
        let row = Row.allCases[indexPath.row]
        
        cell.backgroundColor = SemanticColor.bgGrouped.uiColor
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.font = Typography.bodyLarge
        cell.textLabel?.textColor = SemanticColor.textPrimary.uiColor
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.text = row.title
        
        cell.detailTextLabel?.font = Typography.body
        cell.detailTextLabel?.textColor = SemanticColor.textSecondary.uiColor
        cell.detailTextLabel?.text = nil
        
        switch row {
        case .size:
            cell.detailTextLabel?.text = self.viewModel.moteSizeOption.value.title
        case .gravity:
            cell.detailTextLabel?.text = self.viewModel.gravityOption.value.title
        case .appearance3:
            break
        }
        
        return cell
    }
}

extension MotesEditViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = Row(rawValue: indexPath.row) else { return }
        
        switch row {
        case .size, .gravity:
            self.presentMenu(at: indexPath, for: row)
        case .appearance3:
            break
        }
    }
}

extension MotesEditViewController: UIEditMenuInteractionDelegate {
    
    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        switch self.activeMenuRow {
        case .size:
            return self.sizeMenu()
        case .gravity:
            return self.gravityMenu()
        case .appearance3, .none:
            return nil
        }
    }
}
