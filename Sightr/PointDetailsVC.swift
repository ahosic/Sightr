import UIKit
import GoogleMaps
import Agrume

class PointDetailsVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var guideID:String?
    var point:GuidePoint?
    
    let locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker:GMSMarker!
    let zoomLevel:Float = 14.0
    let markerColor = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1.0)
    let markerImage = UIImage(named: "Pin")
    let markerAnchor = CGPoint(x: 0.25925925925926, y: 1.0)
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressContainer: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var linkContainer: UIView!
    
    @IBOutlet weak var titleContainer: UIVisualEffectView!
    @IBOutlet weak var pointTitle: UILabel!
    @IBOutlet weak var pointText: UITextView!
    @IBOutlet weak var pointAddress: UILabel!
    @IBOutlet weak var pointLink: UILabel!
    @IBOutlet weak var pointImage: UIImageView!
    
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        mapView.delegate = self
        
        provideData()
        fitContent()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.point != nil{
            // Set point location
            self.addLocationMarker((point?.location)!)
        }
    }
    
    /***********  Delegate methods ***********/
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
    }
    
    /***********  Actions ***********/
    
    func imageTapped(img:AnyObject) {
        if let image = pointImage.image {
            let agrume = Agrume(image: image)
            agrume.showFrom(self)
        }
    }
    
    func linkTapped(sender:UITapGestureRecognizer){
        print("tapped")
        
        var link = (point?.link)!
        
        if !link.hasPrefix("http://") && !link.hasPrefix("https://") {
            link = "http://" + link
        }
        
        if let url = NSURL(string: link ) {
            
            
            
            UIApplication.sharedApplication().openURL(url)
        }
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
            if let image = pointImage.image {
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
        locationMarker.icon = markerImage
        locationMarker.groundAnchor = markerAnchor
        locationMarker.opacity = 0.87
        
        // Draw the notification area
        let circle = GMSCircle(position: location, radius: point!.radius)
        
        circle.fillColor = UIColor(red: 84/255, green: 225/255, blue: 214/255, alpha: 0.24)
        circle.strokeColor = UIColor(red: 31/255, green: 173/255, blue: 162/255, alpha: 1)
        circle.strokeWidth = 1
        
        circle.map = mapView;
    }
    
    func provideData() {
        if self.point != nil {
            pointTitle.text = (point?.name)!
            pointText.text = point?.text
            
            if let addr = point?.address {
                pointAddress.text = addr
            } else {
                pointAddress.text = "Not available"
            }
            
            if let link = point?.link {
                if link != "" {
                    pointLink.text = link
                    
                    pointLink.userInteractionEnabled = true
                    pointLink.textColor = UIColor(red: 84/255, green: 225/255, blue: 214/255, alpha: 1.0)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PointDetailsVC.linkTapped(_:)))
                    pointLink.addGestureRecognizer(tapGesture)
                } else {
                    pointLink.text = "Not provided"
                }
            } else {
                pointLink.text = "Not provided"
            }
            
            if (point?.hasImage)! {
                // Load image from image directory
                pointImage.image = FileAccessModel.defaultModel.getImageForPoint(guideID!, imageName: (point?.imageName)!)
                
                let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(PointDetailsVC.imageTapped(_:)))
                pointImage.userInteractionEnabled = true
                pointImage.addGestureRecognizer(tapGestureRecognizer)
            }
        }
    }
    
    func fitContent() {
        // Calculate Height of Text
        let currentSize = pointText.frame.size
        let textContentHeight = pointText.contentSize.height
        let textSize = pointText.sizeThatFits(CGSizeMake(currentSize.width, textContentHeight))
        
        // Calculate total height of content
        var contentHeight = mapView.frame.size.height + addressContainer.frame.size.height + linkContainer.frame.size.height + textSize.height
        
        if pointImage.image == nil {
            contentHeight -= imageContainer.frame.size.height
            imageContainer.hidden = true
        }
        
        // Update Height constraints
        textHeightConstraint.constant = textSize.height
        contentHeightConstraint.constant = contentHeight
        
        // Update ScrollView
        scrollView.contentSize = contentView.frame.size
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        let height = titleContainer.frame.size.height
        self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0,
                                            bottom: height, right: 0)
    }
}
