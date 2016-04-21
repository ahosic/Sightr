import UIKit

class GuidesVC: UITableViewController {
    
    var model = SightrModel()
    
    let guideCell = "guideCell"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(guideCell) as! GuideCell
        cell.name.text = model.guides[indexPath.row].name
        return cell;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.guides.count;
    }
    
    
    @IBAction func createGuide(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Guide", message: "Just enter a name", preferredStyle: .Alert)
        
        // Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(_) in })
        let createAction = UIAlertAction(title: "Create", style: .Default) { (_) in
            let name = alertController.textFields![0] as UITextField
            
            if let text = name.text {
                // Add new Guide
                let idx = self.model.createGuide(text)
                
                // Update Table
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: .Automatic)
                self.tableView.endUpdates()
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
                
                points.guide = model.guides[idx.row]
                //map.guide = model.guides[idx.row]
                
                // Back Item Appearance
                let backItem = UIBarButtonItem()
                backItem.title = ""
                self.navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
