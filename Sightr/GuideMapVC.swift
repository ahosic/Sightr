import UIKit

class GuideMapVC: UIViewController {
    var guide:Guide?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if guide != nil {
            self.tabBarController?.navigationItem.title = guide?.name
        } else {
            self.tabBarController?.navigationItem.title = "Guide"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
