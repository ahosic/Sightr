import UIKit

class AddPointVC: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var pointTitle: UITextField!
    @IBOutlet weak var pointText: UITextView!
    @IBOutlet weak var pointLink: UITextField!
    @IBOutlet weak var pointRadius: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Point"
        
        pointText.delegate = self
    }
    
    /***********  Actions ***********/
    
    func textViewDidChange(textView: UITextView) {
        validateInputs(textView)
    }
    
    @IBAction func validateInputs(sender: AnyObject) {
        let ttl = pointTitle.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let text = pointText.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let radius = pointRadius.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (ttl != nil && ttl != "") && (text != nil && text != "") && (radius != nil && radius != "") {
            if Double(radius!) != nil {
                doneButton.enabled = true
            } else {
                doneButton.enabled = false
            }
        } else {
            doneButton.enabled = false
        }
        
    }
}
