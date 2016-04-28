import Foundation
import UIKit
import CoreLocation

class GuidePoint {
    var id:String
    var name:String
    
    var latitude:Double
    var longitude:Double
    var location:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set(newLocation) {
            self.latitude = newLocation.latitude
            self.longitude = newLocation.longitude
        }
    }
    
    var radius:Double
    var address:String?
    
    var hasImage:Bool = false
    var image:UIImage? {
        didSet {
            hasImage = true
        }
    }
    var text:String
    var link:String?
    
    init(name:String, location:CLLocationCoordinate2D, address:String?, radius:Double, text:String, link:String, image:UIImage?){
        self.id = NSUUID().UUIDString
        self.name = name
        
        self.address = address
        self.radius = radius
        
        self.text = text
        self.link = link
        self.image = image
        
        self.longitude = 0
        self.latitude = 0
        self.location = location
    }
}