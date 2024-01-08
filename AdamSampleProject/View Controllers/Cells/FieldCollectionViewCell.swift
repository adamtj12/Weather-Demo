//  AdamSampleProject

import UIKit

class FieldCollectionViewCell: UICollectionViewCell {
    static let CellIdentifier = "FieldCell"
    static let NibName = "FieldCollectionViewCell"
    static let cellHeight: CGFloat = 73
    static let editableHeight: CGFloat = 73
    static let defaultLabelHeight: CGFloat = 13
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
    }
    
    class func getNibName() -> String {
        return NibNameValue
    }
    
    class func getNibNameSearch() -> String {
        return NibNameValueSearch
    }


}
