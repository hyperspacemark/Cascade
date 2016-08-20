import UIKit.UICollectionViewFlowLayout
import Runes

open class CascadeLayout: UICollectionViewFlowLayout {
    open var delegate: CascadeLayoutDelegate?

    let defaultColumnCount = 1
    let defaultItemSize = CGSize(width: 600, height: 800)

    var sections = [Section]()

    override open var collectionViewContentSize: CGSize {
        guard
            let width = effectiveWidth,
            let height = sections.tallest?.bottomEdge
        else {
            return .zero
        }

        return CGSize(width: width, height: height)
    }

    var effectiveWidth: CGFloat? {
        return collectionView.map { $0.frame.width - $0.contentInset.left - $0.contentInset.right }
    }

    func columnWidthForSectionAtIndex(_ index: Int) -> CGFloat {
        let numberOfColumns = columnCountForSectionAtIndex(index)
        let containerWidth = effectiveWidth ?? 0
        return (containerWidth - minimumLineSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
    }

    override open func prepare() {
        let numberOfSections = collectionView?.numberOfSections ?? 0

        sections = (0..<numberOfSections).reduce([]) { sections, index in
            let numberOfItems = self.collectionView?.numberOfItems(inSection: index) ?? 0
            let columns = self.columnsForSectionAtIndex(index, numberOfItems: numberOfItems, previousSection: sections.last)
            let section = Section(numberOfItems: numberOfItems, columns: columns)
            return sections + [section]
        }
    }

    func columnsForSectionAtIndex(_ index: Int, numberOfItems: Int, previousSection: Section?) -> [Column] {
        let previousBottomEdge = previousSection?.bottomEdge ?? 0
        let numberOfColumns = columnCountForSectionAtIndex(index)
        let columnWidth = columnWidthForSectionAtIndex(index)

        let columns: [Column] = (0..<numberOfColumns).map { columnIndex in
            let minX = CGFloat(columnIndex) * (columnWidth + self.minimumLineSpacing)
            return Column(index: columnIndex, width: columnWidth, minX: minX, minY: previousBottomEdge, spacing: self.minimumInteritemSpacing)
        }

        return (0..<numberOfItems).reduce(columns) { columns, itemIndex in
            let indexPath = IndexPath(item: itemIndex, section: index)
            let itemSize = self.itemSizeAtIndexPath(indexPath)

            if let oldColumn = columns.shortest {
                let newColumn = addItemToColumn(oldColumn, indexPath, itemSize)
                return replaceColumn(columns, oldColumn, newColumn)
            } else {
                return columns
            }
        }
    }

    func columnCountForSectionAtIndex(_ index: Int) -> Int {
        let indexPath = IndexPath(index: index)
        switch (delegate, collectionView) {
        case let (.some(del), .some(collection)):
            return del.collectionView(collection, layout: self, numberOfColumnsInSectionAtIndexPath: indexPath)
        default:
            return defaultColumnCount
        }
    }

    func itemSizeAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        switch (delegate, collectionView) {
        case let (.some(del), .some(collection)):
            return del.collectionView?(collection, layout: self, sizeForItemAt: indexPath) ?? defaultItemSize
        default:
            return defaultItemSize
        }
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return sections.flatMap { $0.itemAttributes }.filter { attributes in
            return rect.intersects(attributes.frame)
        }
    }

    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemAttributes = sections[(indexPath as NSIndexPath).section].itemAttributes
        let index = itemAttributes.map { $0.indexPath }.index(of: indexPath)
        return index.map { itemAttributes[$0] } ?? UICollectionViewLayoutAttributes(forCellWith: indexPath)
    }

    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView?.bounds.width != .some(newBounds.width)
    }

    override open func invalidateLayout() {
        super.invalidateLayout()
        sections = []
    }
}
