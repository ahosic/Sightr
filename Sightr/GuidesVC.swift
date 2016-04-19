import UIKit

class GuidesVC: UITableViewController {
    
    var model = SightrModel()
    
    let guideCell = "guideCell"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigationbar appearance
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Geometria-Light", size: 20)!, NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = .Default
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
}
