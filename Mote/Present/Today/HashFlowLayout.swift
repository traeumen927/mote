//
//  LeftAlignedCollectionViewFlowLayout.swift
//  Mote
//
//  Created by 홍정연 on 3/3/26.
//

import UIKit

// MARK: CollectionView의 Layout을 관리하는 역할 - 여러 아이템이 가로로 나열 되는 형태의 layout, Row단위의 레이아웃을 조정하여 가로 폭을 벗어나지 않도록 함
class HashFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // MARK: 스크롤 최적화
        self.updateEstimatedItemSize()
        
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        // MARK: 행(row) 배열
        var rows = [Row]()
        
        // MARK: 현재 행 초기화(추가하면 0)
        var currentRowY: CGFloat = -1
        
        for attribute in attributes {
            if currentRowY != attribute.frame.origin.y {
                
                // MARK: 현재 처리중인 행의 Y좌표와 현재 아이템의 Y좌표가 다르다면 새로운 행 시작
                currentRowY = attribute.frame.origin.y
                rows.append(Row(spacing: 10))
            }
            
            // MARK: 현재 아이템을 현재 처리중인 행(row)에 추가
            rows.last?.add(attribute: attribute)
        }
        
        rows.forEach { $0.tagLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
        return rows.flatMap { $0.attributes }
    }
    
    // MARK: 아이템의 크기를 정확히 알지 못하기 때문에, 성능 향상을 이유로 미리 설정(스크롤 최적화)
    private func updateEstimatedItemSize() {
        self.estimatedItemSize = CGSize(width: 100, height: 40)
    }
}

// MARK: Row에 속한 아이템의 Layout을 관리
class Row {
    
    // MARK: 특정 행에 속한 아이템들의 레이아웃 속성을 저장하는 배열
    var attributes = [UICollectionViewLayoutAttributes]()
    
    // MARK: 아이템 간의 간격
    var spacing: CGFloat = 0
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    // MARK: 행의 아이템의 레이아웃 속성을 추가
    func add(attribute: UICollectionViewLayoutAttributes) {
        attributes.append(attribute)
    }
    
    // MARK: 특정 행의 아이템들의 위치를 조절하여 레이아웃을 형성
    func tagLayout(collectionViewWidth: CGFloat) {
        let padding = 0
        var offset = padding
        for attribute in attributes {
            attribute.frame.origin.x = CGFloat(offset)
            offset += Int(attribute.frame.width + spacing)
        }
    }
}
