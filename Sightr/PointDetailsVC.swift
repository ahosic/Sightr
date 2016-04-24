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
        pointDesc.text = point?.description
        
        if let link = point?.link {
            if link != ""{
                pointDesc.text = pointDesc.text + "\n\nLink: " + link
            }
        }
        
        if let img = point?.image {
            image.image = img
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
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set point location
        let location = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
        self.addLocationMarker(location)
    }
    
    /***********  Delegate methods ***********/
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
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
        circle.strokeWidth = 2
        
        circle.map = mapView;
    }
}
