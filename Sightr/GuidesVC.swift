import UIKit

class GuidesVC: UITableViewController {
    
    let guideCell = "guideCell"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GuidesVC.update(_:)), name: ModelNotification.GuidesChanged, object: nil)
    }
    
    deinit {
        // Remove Observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ModelNotification.GuidesChanged, object: nil)
    }
    
    /***********  Observer methods ***********/
    
    func update(notification:NSNotification){
        // Get changed index
        let idxPath = notification.userInfo?["indices"] as? [NSIndexPath]
        
        // Get operation type
        let type = notification.userInfo?["operationType"] as? NSString
        
        // Updating TableView
        if idxPath != nil && type != nil {
            
            self.tableView.beginUpdates()
            
            switch type! {
            case ModelOperationType.Add:
                self.tableView.insertRowsAtIndexPaths(idxPath!, withRowAnimation: .Automatic)
            case ModelOperationType.Update:
                self.tableView.reloadRowsAtIndexPaths(idxPath!, withRowAnimation: .Automatic)
            case ModelOperationType.Removed:
                self.tableView.deleteRowsAtIndexPaths(idxPath!, withRowAnimation: .Automatic)
            default: ()
            }
            
            self.tableView.endUpdates()
        }
    }
    
    /***********  TableView methods ***********/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(guideCell) as! GuideCell
        let guide = SightrModel.sharedInstance.guides[indexPath.row]
        
        cell.name.text = guide.name
        cell.itemsCount.text = String(guide.points.count)
        
        return cell;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SightrModel.sharedInstance.guides.count;
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .Normal, title: "Share", handler: {action, index in
            print("Share")
        })
        
        share.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
        
        let edit = UITableViewRowAction(style: .Normal, title: "Edit", handler: {action, index in
            print("Edit")
        })
        
        edit.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
        
        let trash = UITableViewRowAction(style: .Destructive, title: "Trash", handler: {action, index in
            self.removeGuide(index.row)
        })
        
        return [trash, edit, share]
    }
    
    /***********  Actions ***********/
    
    @IBAction func createGuide(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Guide", message: "Just enter a name", preferredStyle: .Alert)
        
        // Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(_) in })
        let createAction = UIAlertAction(title: "Create", style: .Default) { (_) in
            let name = alertController.textFields![0] as UITextField
            
            if let text = name.text {
                // Add new Guide
                SightrModel.sharedInstance.createGuide(text)
            }
        }
        
        createAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler({(textfield) in
            textfield.placeholder = "Name"
            
            // Check, if textfield not empty
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textfield, queue: NSOperationQueue.mainQueue()) { (notification) in
                
                let text = textfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                createAction.enabled = text != ""
            }
        })
        
        // Add actions
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        // Show alert
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGuide" {
            let cell = sender as! GuideCell
            if let idx = tableView.indexPathForCell(cell){
                
                let barVC = segue.destinationViewController as! UITabBarController
                let points = barVC.viewControllers![0] as! GuideDetailsVC
                //let map = barVC.viewControllers![1] as! GuideMapVC
                
                points.guide = SightrModel.sharedInstance.guides[idx.row]
                //map.guide = model.guides[idx.row]
                
                // Back Item Appearance
                let backItem = UIBarButtonItem()
                backItem.title = ""
                self.navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    /***********  Helper methods ***********/
    
    func removeGuide(index:Int){
        let alertController = UIAlertController(title: "Trash", message: "Are your sure you want to remove this guide?", preferredStyle: .Alert)
        
        // Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(_) in })
        let trashAction = UIAlertAction(title: "Remove", style: .Destructive) { (_) in
            // Remove guide
            SightrModel.sharedInstance.removeGuide(index)
        }
        
        // Add actions
        alertController.addAction(trashAction)
        alertController.addAction(cancelAction)
        
        // Show alert
        presentViewController(alertController, animated: true, completion: nil)
    }
}
