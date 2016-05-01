import Foundation
import CoreLocation

class GeofencingModel {
    
    // Singleton pattern
    class var defaultModel:GeofencingModel {
        struct Singleton {
            static let model = GeofencingModel()
        }
        
        return Singleton.model
    }
    
    let locationManager = CLLocationManager()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ModelNotification.GuidesChanged, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ModelNotification.PointsChanged, object: nil)
    }
    
    /*********** Observer methods ***********/
    
    func load() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GeofencingModel.guidesChanged(_:)), name: ModelNotification.GuidesChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GeofencingModel.pointsChanged(_:)), name: ModelNotification.PointsChanged, object: nil)
    }
    
    @objc func guidesChanged(notification:NSNotification) {
        // Get operation type
        let type = notification.userInfo?["operationType"] as? NSString
        
        // Get ID of Guide
        let guideID = notification.userInfo?["guideID"] as? NSString
        
        if type! == ModelOperationType.Removed {
            let removedPoints = notification.userInfo?["removedPoints"] as? [NSString]
            for pointID in removedPoints! {
                remove(guideID! as String, pointID: pointID as String)
            }
        }
    }
    
    @objc func pointsChanged(notification:NSNotification){
        // Get changed index
        let idxPath = notification.userInfo?["indices"] as? [NSIndexPath]
        
        // Get operation type
        let type = notification.userInfo?["operationType"] as? NSString
        
        // Get ID of Guide
        let id = notification.userInfo?["guideID"] as? NSString
        
        if let guideIdx = SightrModel.defaultModel.indexOfGuide(id! as String) {
            let guide = SightrModel.defaultModel.guides[guideIdx]
            
            switch type! {
            case ModelOperationType.Add:
                add(guide, idxPaths: idxPath!)
            case ModelOperationType.Update:
                update(guide, idxPaths: idxPath!)
            case ModelOperationType.Removed:
                let id = notification.userInfo?["pointID"] as? NSString
                remove(guide.id, pointID: id! as String)
            default:
                break
            }
        }
    }
    
    /***********  Geofencing methods ***********/
    
    func add(guide:Guide, idxPaths:[NSIndexPath]) {
        for idx in idxPaths {
            // Get Guide Point
            let point = guide.points[idx.row]
            
            // Create Geofence
            let geoID = guide.id + ";" + point.id
            let region = createGeofence(point.location, radius: point.radius, identifier: geoID)
            
            // Add Geofence
            locationManager.startMonitoringForRegion(region)
        }
    }
    
    func update(guide:Guide, idxPaths:[NSIndexPath]){
        for idx in idxPaths {
            // Get GuidePoint
            let point = guide.points[idx.row]
            let geoID = guide.id + ";" + point.id
            
            if let region = findGeofence(geoID) {
                // Remove old one
                locationManager.stopMonitoringForRegion(region)
                
                // Add new geofence
                let newRegion = createGeofence(point.location, radius: point.radius, identifier: geoID)
                locationManager.startMonitoringForRegion(newRegion)
            }
        }
    }
    
    func remove(guideID:String, pointID:String){
        // Generate region ID
        let geoID = guideID + ";" + pointID
        if let region = findGeofence(geoID){
            locationManager.stopMonitoringForRegion(region)
        }
    }
    
    /***********  Helper methods ***********/
    
    func createGeofence(center:CLLocationCoordinate2D, radius:Double, identifier: String) -> CLCircularRegion {
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnExit = false
        region.notifyOnEntry = true
        
        return region
    }
    
    func findGeofence(identifier: String) -> CLCircularRegion? {
        let regions = locationManager.monitoredRegions.filter {(region) -> Bool in
            if region.identifier == identifier {
                return true
            }
            
            return false
        }
        
        if regions.count > 0 {
            return (regions[0] as? CLCircularRegion)
        } else {
            return nil
        }
    }
}