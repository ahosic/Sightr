import UIKit

class GuideCell: UITableViewCell {
    var guideID:String?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var itemsCount: UILabel!
    @IBOutlet weak var activationStatus: UISwitch!
}
