import UIKit

public protocol CascadeLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CascadeLayout, numberOfColumnsInSectionAtIndexPath indexPath: IndexPath) -> Int
}
