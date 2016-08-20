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

    func addItemWithSize(_ itemSize: CGSize, atIndexPath indexPath: IndexPath) -> Column {
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

func shortestColumn(_ columns: [Column]) -> Column? {
    return columns.sorted { $0.bottomEdge < $1.bottomEdge }.first
}

func tallestColumn(_ columns: [Column]) -> Column? {
    return columns.sorted { $0.bottomEdge > $1.bottomEdge }.first
}

func addItemToColumn(_ column: Column, _ indexPath: IndexPath, _ size: CGSize) -> Column {
    return column.addItemWithSize(size, atIndexPath: indexPath)
}

func replaceColumn(_ columns: [Column], _ oldColumn: Column, _ newColumn: Column) -> [Column] {
    var columns = columns

    if let index = columns.index(of: oldColumn) {
        columns.remove(at: index)
    }

    return columns + [newColumn]
}
