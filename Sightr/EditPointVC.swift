import UIKit
import GoogleMaps

class EditPointVC: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var imageCell: UITableViewCell!
    
    @IBOutlet weak var pointTitle: UITextField!
    @IBOutlet weak var pointText: UITextView!
    @IBOutlet weak var pointLink: UITextField!
    @IBOutlet weak var pointRadius: UITextField!
    @IBOutlet weak var pointImage: UIImageView!
    
    var pointAddress:String?
    var pointLocation:CLLocationCoordinate2D?
    
    var point:GuidePoint?
    var placePicker:GMSPlacePicker?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pointText.delegate = self
        imagePicker.delegate = self
        
        self.pointTitle.text = point?.name
        self.pointText.text = point?.description
        self.pointLink.text = point?.link
        self.pointRadius.text = String(point!.radius)
        
        if let image = point?.image {
            self.pointImage.image = image
            self.imageCell.hidden = false
        }
        
        self.pointAddress = point?.address
        self.pointLocation = point?.location
    }
    
    /***********  TableView methods ***********/
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 2 {
            showActionsForImagePicking()
        }
        
        if indexPath.row == 1 && indexPath.section == 1 {
            showPlacePicker()
        }
    }
    
    /***********  Actions ***********/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Back Item Appearance
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }
    
    func textViewDidChange(textView: UITextView) {
        validateInputs(textView)
    }
    
    @IBAction func validateInputs(sender: AnyObject) {
        let ttl = pointTitle.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let text = pointText.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let radius = pointRadius.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (ttl != nil && ttl != "") && (text != nil && text != "") && (radius != nil && radius != "") && pointLocation != nil{
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
    
    func showPlacePicker() {
        // Configure place picker
        let center = point?.location //CLLocationCoordinate2DMake(48.306173, 14.286371)
        let northEast = CLLocationCoordinate2DMake(center!.latitude + 0.001, center!.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center!.latitude - 0.001, center!.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let place = place {
                self.pointLocation = place.coordinate
                self.pointAddress = place.formattedAddress
                self.validateInputs(self.placePicker!)
            }
        })
    }
    
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
