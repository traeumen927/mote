//
//  TodayViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TodayViewController: UIViewController {
    
    private let viewModel: TodayViewModel
    
    private let disposeBag = DisposeBag()
    private var selectedIndexPath: IndexPath?
    private let collectionViewHeight: CGFloat = 160
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Emotion"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = SemanticColor.textPrimary.uiColor
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = .zero
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.allowsMultipleSelection = false
        view.register(TodayEmotionCell.self, forCellWithReuseIdentifier: TodayEmotionCell.cellId)
        view.dataSource = self
        return view
    }()
    
    private let captionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = SemanticColor.bgSurface.uiColor
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let captionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14, weight: .regular)
        textView.textColor = SemanticColor.textPrimary.uiColor
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Today's Emotion", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = SemanticColor.accentPrimary.uiColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.alpha = 0.4
        return button
    }()
    
    init(viewModel: TodayViewModel) {
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
        
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.captionContainerView)
        self.captionContainerView.addSubview(self.captionTextView)
        self.view.addSubview(self.saveButton)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(self.collectionViewHeight)
        }
        
        self.captionContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.collectionView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        self.captionTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        self.saveButton.snp.makeConstraints { make in
            make.top.equalTo(self.captionContainerView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func bind() {
        self.saveButton.rx.tap
            .bind { [weak self] in
                self?.saveSelectedEmotion()
            }
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.selectedIndexPath = indexPath
                self?.captionContainerView.isHidden = false
                self?.saveButton.isEnabled = true
                self?.saveButton.alpha = 1.0
            }
            .disposed(by: self.disposeBag)
    }
    
    private func saveSelectedEmotion() {
        guard let indexPath = self.selectedIndexPath else { return }
        
        guard let record = self.viewModel.saveTodayEmotion(selectedIndex: indexPath.item, caption: self.captionTextView.text) else {
            self.showAlert(title: "Already Saved", message: "You already saved your emotion today. Please try again tomorrow.")
            return
        }
        
        let message = record.caption == nil
        ? "Saved emotion: \(record.emotion)."
        : "Saved emotion and caption: \(record.emotion)."
        self.showAlert(title: "Saved", message: message)
        self.saveButton.isEnabled = false
        self.saveButton.alpha = 0.4
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayEmotionCell.cellId, for: indexPath) as? TodayEmotionCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: self.viewModel.items[indexPath.item])
        return cell
    }
}

