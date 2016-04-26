import UIKit
import GoogleMaps

class GuideMapVC: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var guide:Guide?
    var didFindMyLocation = false
    var zoomed = true
    let zoomLevel:Float = 14.0
    
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
        mapView.removeObserver(self, forKeyPath: "myLocation")
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
            locationMarker.icon = GMSMarker.markerImageWithColor(UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1.0))
            locationMarker.opacity = 0.87
            
            // Draw the notification area
            let circle = GMSCircle(position: point.location, radius: point.radius)
            
            circle.fillColor = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 0.24)
            circle.strokeColor = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1)
            circle.strokeWidth = 1
            
            circle.map = mapView;
        }
    }
    
}
