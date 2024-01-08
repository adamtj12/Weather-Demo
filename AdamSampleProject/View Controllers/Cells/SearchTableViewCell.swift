//  AdamSampleProject

import UIKit


class SearchTableViewCell: TitleTwoSubTitleTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getNibName() -> String {
        return NibNameValue
    }
}
