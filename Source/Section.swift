import CoreGraphics.CGGeometry
import UIKit.UICollectionViewLayout

struct Section {
    let numberOfItems: Int
    let columns: [Column]

    var itemAttributes: [UICollectionViewLayoutAttributes] {
        let attributes = columns.map { $0.attributes }
        return Array(attributes.joined())
    }

    var bottomEdge: CGFloat {
        return columns.tallest?.bottomEdge ?? 0
    }

    init(numberOfItems: Int, columns: [Column]) {
        self.numberOfItems = numberOfItems
        self.columns = columns
    }
}

extension Sequence where Iterator.Element == Section {
    var tallest: Section? {
        return self.max { $0.bottomEdge < $1.bottomEdge }
    }
}
