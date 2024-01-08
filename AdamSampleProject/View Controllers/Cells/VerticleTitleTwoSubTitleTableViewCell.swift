//  AdamSampleProject

import UIKit


class VerticleTitleTwoSubTitleTableViewCell: TitleTwoSubTitleTableViewCell {

    @IBOutlet weak var tempLabel: UILabel! {
        didSet {
            apparentTempLabel.textColor = UIColor.white
        }
    }

    
    @IBOutlet weak var cloudCoverLabel: UILabel! {
        didSet {
            cloudCoverLabel.textColor = UIColor.white
        }
    }
        
    @IBOutlet weak var rainLabel: UILabel! {
        didSet {
            rainLabel.textColor = UIColor.white
        }
    }

    @IBOutlet weak var apparentTempLabel: UILabel! {
        didSet {
            apparentTempLabel.textColor = UIColor.white
        }
    }

    @IBOutlet weak var intervalLabel: UILabel! {
        didSet {
            intervalLabel.textColor = UIColor.white
        }
    }

    @IBOutlet weak var windGustsLabel: UILabel! {
        didSet {
            windGustsLabel.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var windDirectionLabel: UILabel! {
        didSet {
            windDirectionLabel.textColor = UIColor.white
        }
    }

    
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
