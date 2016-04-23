import UIKit
import GoogleMaps

class EditPointLocationVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var pickedLocation:CLLocationCoordinate2D?
    
    let locationManager = CLLocationManager()
    var didFindMyLocation = true
    var locationMarker: GMSMarker!
    var mapTasks = MapTasks()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        if let location = pickedLocation {
            mapView.camera = GMSCameraPosition.cameraWithTarget(location, zoom: 10.0)
            
            mapView.settings.myLocationButton = true
            self.doneButton.enabled = true
            self.addLocationMarker(location)
        }
    }
    
    deinit {
        mapView.removeObserver(self, forKeyPath: "myLocation")
    }
    
    /***********  Delegate methods ***********/
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            // Get location
            let location:CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            
            // Zoom to location
            mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            
            self.didFindMyLocation = true
        }
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        pickedLocation = coordinate
        doneButton.enabled = true
        addLocationMarker(coordinate)
    }
    
    /***********  Actions ***********/
    
    @IBAction func searchAddress(sender: AnyObject) {
        let alertController = UIAlertController(title: "Search", message: "Type an address", preferredStyle: .Alert)
        
        // Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(_) in })
        let searchAction = UIAlertAction(title: "Search", style: .Default) { (_) in
            
            if let text = alertController.textFields![0].text {
                // Search
                self.startSearchingAddress(text)
            }
        }
        
        searchAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler({(textfield) in
            textfield.placeholder = "Address"
            
            // Check, if textfield not empty
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textfield, queue: NSOperationQueue.mainQueue()) { (notification) in
                
                let text = textfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                searchAction.enabled = text != ""
            }
        })
        
        // Add actions
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        
        // Show alert
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    /***********  Helper methods ***********/
    
    func startSearchingAddress(address:String) {
        // Geocoding
    }
    
    func addLocationMarker(location:CLLocationCoordinate2D){
        if locationMarker != nil {
            locationMarker.map = nil
        }
        
        // Zoom to location
        mapView.camera = GMSCameraPosition.cameraWithTarget(location, zoom: mapView.camera.zoom)
        
        locationMarker = GMSMarker(position: location)
        locationMarker.map = mapView
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1.0))
        locationMarker.opacity = 0.87
    }
    
}
