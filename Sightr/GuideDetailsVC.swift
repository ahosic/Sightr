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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GuideDetailsVC.update(_:)), name: ModelNotification.PointsChanged, object: nil)
    }
    
    deinit {
        // Remove observers
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ModelNotification.PointsChanged, object: nil)
    }
    
    /***********  Observer methods ***********/
    
    func update(notification:NSNotification){
        // Get changed index
        let id = notification.userInfo?["guideID"] as? NSString
        let type = notification.userInfo?["operationType"] as? NSString
        
        // If update for current guide -> update tableView
        if id != nil && id == guide?.id && type != nil {
            if let idxPath = notification.userInfo?["indices"] as? [NSIndexPath] {
                
                self.tableView.beginUpdates()
                
                switch type! {
                case ModelOperationType.Add:
                    self.tableView.insertRowsAtIndexPaths(idxPath, withRowAnimation: .Automatic)
                case ModelOperationType.Removed:
                    self.tableView.deleteRowsAtIndexPaths(idxPath, withRowAnimation: .Automatic)
                default: ()
                }
                
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
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "Edit", handler: {action, index in
            print("Edit")
        })
        
        edit.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
        
        let trash = UITableViewRowAction(style: .Destructive, title: "Trash", handler: {action, index in
            self.removePoint(index.row)
        })
        
        return [trash, edit]
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
    
    /***********  Helper methods ***********/
    
    func removePoint(index:Int){
        let alertController = UIAlertController(title: "Trash", message: "Are your sure you want to remove this point?", preferredStyle: .Alert)
        
        // Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(_) in })
        let trashAction = UIAlertAction(title: "Remove", style: .Destructive) { (_) in
            // Remove guide
            SightrModel.sharedInstance.removePointOfGuide(self.guide!, index: index)
        }
        
        // Add actions
        alertController.addAction(trashAction)
        alertController.addAction(cancelAction)
        
        // Show alert
        presentViewController(alertController, animated: true, completion: nil)
    }
}
