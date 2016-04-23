import UIKit

class GuideDetailsVC: UITableViewController {
    
    var guide:Guide?
    let textCellID = "textPointCell"
    
    
    @IBOutlet weak var add: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set title of view
        if guide != nil {
            self.tabBarController?.navigationItem.title = guide?.name
        } else {
            self.tabBarController?.navigationItem.title = "Guide"
        }
        
        self.tabBarController?.navigationItem.rightBarButtonItems = [add]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GuideDetailsVC.updateGuideDetailsOnPointAdded(_:)), name: ModelNotification.PointsAdded, object: nil)
    }
    
    deinit {
        // Remove observers
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ModelNotification.PointsAdded, object: nil)
    }
    
    /***********  Observer methods ***********/
    
    func updateGuideDetailsOnPointAdded(notification:NSNotification){
        // Get changed index
        let id = notification.userInfo?["guideID"] as? NSString
        
        // If update for current guide -> update tableView
        if id != nil && id == guide?.id {
            if let idxPath = notification.userInfo?["indices"] as? [NSIndexPath] {
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths(idxPath, withRowAnimation: .Automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    /***********  TableView methods ***********/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if guide != nil {
            return (guide?.points.count)!
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let point = guide?.points[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellID) as! GuidePointCell
        
        cell.title.text = point?.name
        cell.subtitle.text = point?.description
        
        return cell
    }
    
    /***********  Actions ***********/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Back Item Appearance
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.tabBarController?.navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func addPoint(segue: UIStoryboardSegue) {
        if let addPoint = segue.sourceViewController as? AddPointVC {
            // Trim data
            let ttl = addPoint.pointTitle.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let desc = addPoint.pointText.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let radius = addPoint.pointRadius.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let link = addPoint.pointLink.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let image = addPoint.pointImage.image
            let location = addPoint.location
            
            // Create and save point
            let point = GuidePoint(name: ttl!,
                                   longitude: (location?.longitude)!,
                                   latitude: (location?.latitude)!,
                                   radius: Double(radius!)!,
                                   description: desc!,
                                   link: link!,
                                   image: image)
            
            SightrModel.sharedInstance.addPointToGuide(guide!, point: point)
        }
    }
}
