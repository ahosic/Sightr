import UIKit
import GoogleMaps

class GuideMapVC: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var guide:Guide?
    var didFindMyLocation = false
    var zoomed = true
    let zoomLevel:Float = 14.0
    let markerImage = UIImage(named: "Pin")
    let markerAnchor = CGPoint(x: 0.25925925925926, y: 1.0)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if guide != nil {
            self.tabBarController?.navigationItem.title = guide?.name
        } else {
            self.tabBarController?.navigationItem.title = "Guide"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        mapView.myLocationEnabled = true
        
        let height = tabBarController?.tabBar.frame.size.height
        self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0,
                                            bottom: height!, right: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add markers for all points
        addLocationMarkersForPoints()
    }
    
    deinit {
        if mapView != nil {
            mapView.removeObserver(self, forKeyPath: "myLocation")
        }
    }
    
    /***********  Observer methods ***********/
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            // Add myLocation button
            mapView.settings.myLocationButton = true
            
            self.didFindMyLocation = true
        }
    }
    
    /***********  Helper methods ***********/
    
    func addLocationMarkersForPoints(){
        // Zoom to location of the first point
        if guide?.points.count > 0 {
            mapView.camera = GMSCameraPosition.cameraWithTarget((guide?.points[0].location)!, zoom: zoomLevel)
        } else {
            let alert = UIAlertController(title: "No points found!", message: "What about adding some points first?", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Got it", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
        
        // Add markers for all points
        for point in (guide?.points)!{
            let locationMarker = GMSMarker(position: point.location)
            locationMarker.map = mapView
            
            locationMarker.appearAnimation = kGMSMarkerAnimationPop
            locationMarker.icon = markerImage
            locationMarker.groundAnchor = markerAnchor
            locationMarker.opacity = 0.87
            
            locationMarker.title = point.name
            locationMarker.snippet = point.address
            locationMarker.infoWindowAnchor = CGPointMake(markerAnchor.x, 0.0)
            
            
            // Draw the notification area
            let circle = GMSCircle(position: point.location, radius: point.radius)
            
            circle.fillColor = UIColor(red: 84/255, green: 225/255, blue: 214/255, alpha: 0.12)
            circle.strokeColor = UIColor(red: 31/255, green: 173/255, blue: 162/255, alpha: 1)
            circle.strokeWidth = 1
            
            circle.map = mapView;
        }
    }
    
}
