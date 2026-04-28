//
//  HistoryViewController.swift
//  Mote
//
//  Created by 홍정연 on 4/28/26.
//

import UIKit
import SnapKit

final class HistoryViewController: UIViewController {
    private let viewModel: HistoryViewModel
    private var itemByID: [String: HistoryViewModel.Item] = [:]
    private lazy var dataSource = self.makeDataSource()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        tableView.register(HistoryEmotionCell.self, forCellReuseIdentifier: HistoryEmotionCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var footerLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
        container.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.tableView.tableFooterView = container
        return indicator
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }()
    
    init(viewModel: HistoryViewModel) {
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
        self.viewModel.loadInitial()
    }
    
    private func setupLayout() {
        self.navigationItem.title = "History"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.loadingIndicator)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bind() {
        self.viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            self.itemByID = Dictionary(uniqueKeysWithValues: state.items.map { ($0.dateKey, $0) })
            self.apply(state.items.map(\.dateKey))
            
            if state.isLoading && state.items.isEmpty {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
            
            if state.isLoadingMore {
                self.footerLoadingIndicator.startAnimating()
            } else {
                self.footerLoadingIndicator.stopAnimating()
            }
            
            if let errorMessage = state.errorMessage {
                let alert = UIAlertController(title: "오류", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, String> {
        return UITableViewDiffableDataSource<Int, String>(tableView: self.tableView) { [weak self] tableView, indexPath, itemID in
            guard let self,
                  let item = self.itemByID[itemID],
                  let cell = tableView.dequeueReusableCell(withIdentifier: HistoryEmotionCell.reuseIdentifier, for: indexPath) as? HistoryEmotionCell else {
                return UITableViewCell()
            }
            
            let createdAtText: String
            if let createdAt = item.createdAt {
                createdAtText = self.dateFormatter.string(from: createdAt)
            } else {
                createdAtText = "-"
            }
            
            cell.configure(
                emotion: item.emotion,
                caption: item.caption,
                isHidden: item.isHidden,
                createdAtText: createdAtText
            )
            cell.onHiddenSwitchChanged = { [weak self] isOn in
                self?.viewModel.updateHidden(dateKey: item.dateKey, isHidden: isOn)
            }
            
            return cell
        }
    }
    
    private func apply(_ itemIDs: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(itemIDs, toSection: 0)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension HistoryViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y <= 0 else { return }
        self.viewModel.loadMoreIfNeeded()
    }
}

