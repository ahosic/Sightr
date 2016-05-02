import UIKit
import GoogleMaps

class PointDetailsVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var point:GuidePoint?
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var pointDesc: UITextView!
    
    let locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker:GMSMarker!
    let zoomLevel:Float = 14.0
    let markerColor = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1.0)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set Point data
        self.title = point?.name
        pointDesc.text = point?.text
        
        if let link = point?.link {
            if link != ""{
                pointDesc.text = pointDesc.text + "\n\nLink: " + link
            }
        }
        
        if (point?.hasImage)! {
            // Load image from image directory
            let path = SightrModel.defaultModel.getImagesDirectory().stringByAppendingPathComponent((point?.id)! + ".jpg")
            image.image = UIImage(contentsOfFile: path)
            image.hidden = false
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(PointDetailsVC.imageTapped(_:)))
            image.userInteractionEnabled = true
            image.addGestureRecognizer(tapGestureRecognizer)
        }
        
        // Adjust size of textview to actual length of text
        let descWidth = self.pointDesc.frame.size.width
        let newSize = self.pointDesc.sizeThatFits(CGSize(width: descWidth, height: CGFloat.max))
        
        var newFrame = self.pointDesc.frame
        newFrame.size = CGSize(width: max(newSize.width, descWidth), height: newSize.height)
        self.pointDesc.frame = newFrame;
        self.pointDesc.scrollEnabled = false
        
        // Set scroll View
        scroll.contentSize = self.view.frame.size
        scroll.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set point location
        self.addLocationMarker((point?.location)!)
    }
    
    /***********  Delegate methods ***********/
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
    }
    
    /***********  Actions ***********/
    
    func imageTapped(img:AnyObject) {
    }
    
    @IBAction func share(sender: AnyObject) {
        // Construct string for sharing
        var textToShare = "\((point?.name)!)\n\((point?.text)!)\n"
        
        if point?.address != nil && point?.address != "" {
            textToShare = textToShare + "Location: \((point?.address)!)"
            
        }
        
        var objectsToShare:NSArray = []
        if (point?.hasImage)! {
            // Load image from image directory
            let path = SightrModel.defaultModel.getImagesDirectory().stringByAppendingPathComponent((point?.id)! + ".jpg")
            if let image = UIImage(contentsOfFile: path) {
                objectsToShare = [textToShare, image]
            }
            
        } else {
            objectsToShare = [textToShare]
        }
        
        let activity = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)
        self.presentViewController(activity, animated: true, completion: nil)
    }
    /***********  Helper methods ***********/
    
    func addLocationMarker(location:CLLocationCoordinate2D){
        if locationMarker != nil {
            locationMarker.map = nil
        }
        
        // Zoom to location
        mapView.camera = GMSCameraPosition.cameraWithTarget(location, zoom: zoomLevel)
        
        // Add marker
        locationMarker = GMSMarker(position: location)
        locationMarker.map = mapView
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(markerColor)
        locationMarker.opacity = 0.87
        
        // Draw the notification area
        let circle = GMSCircle(position: location, radius: point!.radius)
        
        circle.fillColor = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 0.24)
        circle.strokeColor = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1)
        circle.strokeWidth = 1
        
        circle.map = mapView;
    }
}
