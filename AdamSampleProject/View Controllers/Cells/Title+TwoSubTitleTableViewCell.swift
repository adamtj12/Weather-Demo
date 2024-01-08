//  AdamSampleProject


import UIKit


class TitleTwoSubTitleTableViewCell: DefaultTableViewCell {
    static let CellIdentifier = "Title+TwoSubTitleTableViewCell"
    static let NibName = "Title+TwoSubTitleTableViewCell"
    static let CellHeight: CGFloat = 100

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.white
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }
    
    deinit {
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }

}
