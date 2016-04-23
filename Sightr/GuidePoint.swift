import Foundation
import UIKit

class GuidePoint {
    var id:String
    var name:String
    
    var longitude:Double
    var latitude:Double
    var radius:Double
    
    var image:UIImage?
    var description:String
    var link:String?
    
    init(name:String, longitude:Double, latitude:Double, radius:Double, description:String, link:String, image:UIImage?){
        self.id = NSUUID().UUIDString
        self.name = name
        
        self.longitude = longitude
        self.latitude = latitude
        self.radius = radius
        
        self.description = description
        self.link = link
        self.image = image
    }
}