import UIKit

class AddPointVC: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var imageCell: UITableViewCell!
    
    @IBOutlet weak var pointTitle: UITextField!
    @IBOutlet weak var pointText: UITextView!
    @IBOutlet weak var pointLink: UITextField!
    @IBOutlet weak var pointRadius: UITextField!
    @IBOutlet weak var pointImage: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Point"
        
        pointText.delegate = self
        imagePicker.delegate = self
    }
    
    /***********  TableView methods ***********/
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 2 {
            showActionsForImagePicking()
        }
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
    
    @IBAction func pickImage(sender: AnyObject) {
        showActionsForImagePicking()
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pointImage.image = pickedImage
            self.imageCell.hidden = false
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /***********  Helper methods ***********/
    
    func showActionsForImagePicking() {
        let imagePickerOptions = UIAlertController(title: nil, message: "Choose a image source", preferredStyle: .ActionSheet)
        
        // Actions
        let takeAction = UIAlertAction(title: "Take a photo", style: .Default, handler: takePhoto)
        let chooseAction = UIAlertAction(title: "Choose from gallery", style: .Default, handler: chooseImageFromGallery)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        // Add actions to action sheet
        imagePickerOptions.addAction(takeAction)
        imagePickerOptions.addAction(chooseAction)
        imagePickerOptions.addAction(cancelAction)
        
        // Show
        self.presentViewController(imagePickerOptions, animated: true, completion: nil)
    }
    
    func takePhoto(alert:UIAlertAction!) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        
        // Show ImagePicker
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func chooseImageFromGallery(alert:UIAlertAction!){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        // Show ImagePicker
        presentViewController(imagePicker, animated: true, completion: nil)
    }
}
