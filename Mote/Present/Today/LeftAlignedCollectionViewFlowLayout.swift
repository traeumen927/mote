//
//  LeftAlignedCollectionViewFlowLayout.swift
//  Mote
//
//  Created by 홍정연 on 3/3/26.
//

import UIKit

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        let copiedAttributes = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        var currentLeft = self.sectionInset.left
        var currentY: CGFloat = -1
        
        copiedAttributes
            .filter { $0.representedElementCategory == .cell }
            .forEach { attribute in
                if abs(attribute.frame.origin.y - currentY) > 1 {
                    currentLeft = self.sectionInset.left
                    currentY = attribute.frame.origin.y
                }
                
                attribute.frame.origin.x = currentLeft
                currentLeft = attribute.frame.maxX + self.minimumInteritemSpacing
            }
        
        return copiedAttributes
    }
}
