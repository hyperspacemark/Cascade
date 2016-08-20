import CoreGraphics.CGGeometry
import UIKit.UICollectionViewLayout
import Foundation.NSIndexPath
import Runes

struct Column {
    let index: Int
    let frame: CGRect
    let width: CGFloat
    let attributes: [UICollectionViewLayoutAttributes]
    let spacing: CGFloat

    var bottomEdge: CGFloat {
        return frame.maxY
    }

    init(index: Int, width: CGFloat, minX: CGFloat, minY: CGFloat, spacing: CGFloat) {
        self.index = index
        self.width = width
        self.attributes = []
        self.frame = CGRect(x: minX, y: minY, width: width, height: 0)
        self.spacing = spacing
    }
}

extension Column {
    init(column: Column, frame: CGRect, attributes: [UICollectionViewLayoutAttributes]) {
        self.index = column.index
        self.width = column.width
        self.frame = frame
        self.attributes = attributes
        self.spacing = column.spacing
    }

    func appendItem(with itemSize: CGSize, at indexPath: IndexPath) -> Column {
        let aspectRatio = itemSize.height / itemSize.width
        let itemRect = CGRect(x: frame.minX,
            y: bottomEdge + spacing,
            width: floor(width),
            height: floor(width * aspectRatio))

        let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        itemAttributes.frame = itemRect

        let newAttributes = attributes + [itemAttributes]
        let newFrame = frame.union(itemRect)

        return Column(column: self, frame: newFrame, attributes: newAttributes)
    }
}

extension Column: Equatable {
    static func ==(lhs: Column, rhs: Column) -> Bool {
        return (lhs.index == rhs.index) && (lhs.bottomEdge == rhs.bottomEdge)
    }
}

extension Sequence where Iterator.Element == Column {
    var shortest: Column? {
        return self.min(by: bottomEdgesInIncreasingOrder)
    }

    var tallest: Column? {
        return self.max(by: bottomEdgesInIncreasingOrder)
    }

    private func bottomEdgesInIncreasingOrder(lhs: Column, rhs: Column) -> Bool {
        return lhs.bottomEdge < rhs.bottomEdge
    }
}

extension RangeReplaceableCollection where Iterator.Element == Column {
    func replacing(_ oldColumn: Column, with newColumn: Column) -> Self {
        var mutable = self
        mutable.replace(oldColumn, with: newColumn)
        return mutable
    }
    
    mutating func replace(_ oldColumn: Column, with newColumn: Column) {
        guard let index = self.index(of: oldColumn) else {
            preconditionFailure()
        }
        
        let range = ClosedRange(uncheckedBounds: (index, index))
        replaceSubrange(range, with: [newColumn])
    }
}
