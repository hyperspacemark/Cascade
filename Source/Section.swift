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
        return tallestColumn(columns)?.bottomEdge ?? 0
    }

    init(numberOfItems: Int, columns: [Column]) {
        self.numberOfItems = numberOfItems
        self.columns = columns
    }
}

func tallestSection(_ sections: [Section]) -> Section? {
    return sections.sorted { $0.bottomEdge > $1.bottomEdge }.first
}
