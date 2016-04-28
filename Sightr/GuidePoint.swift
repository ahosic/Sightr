import Foundation
import UIKit
import CoreLocation
import RealmSwift

class GuidePoint : Object {
    dynamic var id:String = ""
    dynamic var name:String = ""
    
    dynamic var latitude:Double = 0.0
    dynamic var longitude:Double = 0.0
    var location:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set(newLocation) {
            self.latitude = newLocation.latitude
            self.longitude = newLocation.longitude
        }
    }
    
    dynamic var radius:Double = 0.0
    dynamic var address:String? = nil
    
    dynamic var hasImage:Bool = false
    var image:UIImage? {
        didSet {
            hasImage = true
        }
    }
    dynamic var text:String = ""
    dynamic var link:String? = nil
    
    override static func ignoredProperties() -> [String] {
        return ["location", "image"]
    }
    
    convenience init(name:String, location:CLLocationCoordinate2D, address:String?, radius:Double, text:String, link:String, image:UIImage?){
        self.init()
        
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