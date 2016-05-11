import UIKit
import SwiftSpinner

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
        let guide = SightrModel.defaultModel.guides[indexPath.row]
        
        cell.guideID = guide.id
        cell.name.text = guide.name
        cell.itemsCount.text = String(guide.points.count)
        cell.activationStatus.on = guide.isActivated
        
        return cell;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SightrModel.defaultModel.guides.count;
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .Normal, title: "Share", handler: {action, index in
            self.shareGuide(index.row)
        })
        
        share.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
        
        let edit = UITableViewRowAction(style: .Normal, title: "Edit", handler: {action, index in
            self.editGuide(index.row)
        })
        
        edit.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
        
        let trash = UITableViewRowAction(style: .Destructive, title: "Trash", handler: {action, index in
            self.removeGuide(index.row)
        })
        
        return [trash, edit, share]
    }
    
    /***********  Actions ***********/
    
    @IBAction func activationChanged(sender: UISwitch) {
        let cell = sender.superview?.superview as! GuideCell
        if let id = cell.guideID {
            SightrModel.defaultModel.toggleActivationOfGuide(id)
        }
    }
    
    @IBAction func createGuide(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Guide", message: "Just enter a name", preferredStyle: .Alert)
        
        // Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(_) in })
        let createAction = UIAlertAction(title: "Create", style: .Default) { (_) in
            let name = alertController.textFields![0] as UITextField
            
            if let text = name.text {
                // Add new Guide
                SightrModel.defaultModel.createGuide(text)
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
                let map = barVC.viewControllers![1] as! GuideMapVC
                
                points.guide = SightrModel.defaultModel.guides[idx.row]
                map.guide = SightrModel.defaultModel.guides[idx.row]
                
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
            SightrModel.defaultModel.removeGuide(index)
        }
        
        // Add actions
        alertController.addAction(trashAction)
        alertController.addAction(cancelAction)
        
        // Show alert
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func editGuide(index:Int){
        let guide = SightrModel.defaultModel.guides[index]
        let alertController = UIAlertController(title: "Edit Guide", message: "Set the guide's name", preferredStyle: .Alert)
        
        // Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(_) in })
        let editAction = UIAlertAction(title: "Done", style: .Default) { (_) in
            let name = alertController.textFields![0] as UITextField
            
            if let text = name.text {
                // Update guide
                SightrModel.defaultModel.updateGuide(guide, name: text)
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler({(textfield) in
            textfield.text = guide.name
            
            // Check, if textfield not empty
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textfield, queue: NSOperationQueue.mainQueue()) { (notification) in
                
                let text = textfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                editAction.enabled = text != ""
            }
        })
        
        // Add actions
        alertController.addAction(editAction)
        alertController.addAction(cancelAction)
        
        // Show alert
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func shareGuide(index:Int) {
        SwiftSpinner.setTitleFont(UIFont(name: "Quicksand-Regular", size: 20.0))
        SwiftSpinner.show("Preparing for share", animated: true)
        
        let guide = SightrModel.defaultModel.guides[index]
        let fileUrl = FileAccessModel.defaultModel.serializeGuide(guide)
        
        delay(seconds: 2.0, fileURL: fileUrl) { fileURL in
            SwiftSpinner.hide()
            
            if let fileURL = fileURL {
                dispatch_async(dispatch_get_main_queue()){
                    
                    // Initialize ActivityViewController
                    let airDropController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                    
                    // Exclude Activity Types
                    airDropController.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeMail]
                    
                    airDropController.completionWithItemsHandler = {
                        (activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                        
                        if let zipPath = fileURL.path {
                            // Delete prepared Sightr archive
                            FileAccessModel.defaultModel.removeFileOrDirectory(zipPath)
                        }
                    }
                    
                    // Show
                    self.presentViewController(airDropController, animated: true) {
                        self.tableView.setEditing(false, animated: true)
                    }
                }
            }
        }
    }
    
    func delay(seconds seconds: Double, fileURL:NSURL?, completion:(NSURL?)->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion(fileURL)
        }
    }
    
}
