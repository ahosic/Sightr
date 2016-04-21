import UIKit

class GuideDetailsVC: UITableViewController {
    var guide:Guide?
    let textCellID = "textPointCell"
    
    
    @IBOutlet weak var add: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if guide != nil {
            self.tabBarController?.navigationItem.title = guide?.name
        } else {
            self.tabBarController?.navigationItem.title = "Guide"
        }
        
        self.tabBarController?.navigationItem.rightBarButtonItems = [add]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPoint" {
        }
        
        // Back Item Appearance
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.tabBarController?.navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func addPoint(segue: UIStoryboardSegue) {
    }
}
