import Foundation
import UIKit
import CoreLocation

class GuidePoint {
    var id:String
    var name:String
    
    var location:CLLocationCoordinate2D
    var radius:Double
    var address:String?
    
    var image:UIImage?
    var description:String
    var link:String?
    
    init(name:String, location:CLLocationCoordinate2D, address:String?, radius:Double, description:String, link:String, image:UIImage?){
        self.id = NSUUID().UUIDString
        self.name = name
        
        self.location = location
        self.address = address
        self.radius = radius
        
        self.description = description
        self.link = link
        self.image = image
    }
}