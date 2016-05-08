import Foundation
import UIKit
import CoreLocation
import RealmSwift
import SwiftyJSON

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
    dynamic var imageName:String? = nil
    dynamic var text:String = ""
    dynamic var link:String? = nil
    
    override static func ignoredProperties() -> [String] {
        return ["location", "image"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name:String, location:CLLocationCoordinate2D, address:String?, radius:Double, text:String, link:String?, imageName:String?){
        self.init()
        self.id = NSUUID().UUIDString
        self.name = name
        
        self.address = address
        self.radius = radius
        
        self.text = text
        self.link = link
        
        self.longitude = 0
        self.latitude = 0
        self.location = location
        self.imageName = imageName
        
        if imageName != nil {
            self.hasImage = true
        } else {
            self.hasImage = false
        }
    }
    
    convenience init(json:JSON) {
        self.init()
        
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        
        self.address = json["address"].string
        self.radius = json["radius"].doubleValue
        
        self.text = json["text"].stringValue
        self.link = json["link"].string
        self.hasImage = json["hasImage"].boolValue
        self.imageName = json["imageName"].string
        self.longitude = json["longitude"].doubleValue
        self.latitude = json["latitude"].doubleValue
    }
    
    func toJSON() -> String {
        let pointID = NSUUID().UUIDString
        
        var json = "{"
        
        json += "\"id\": \"\(pointID)\","
        json += "\"name\": \"\(self.name)\","
        json += "\"latitude\": \"\(self.latitude)\","
        json += "\"longitude\": \"\(self.longitude)\","
        json += "\"radius\": \"\(self.radius)\","
        json += "\"text\": \"\(self.text)\","
        json += "\"hasImage\": \"\(self.hasImage)\","
        
        if imageName != nil {
            json += "\"imageName\": \"\(self.imageName!)\","
        } else {
            json += "\"imageName\": null,"
        }
        
        if address != nil {
            json += "\"address\": \"\(self.address!)\","
        } else {
            json += "\"address\": null,"
        }
        
        if link != nil {
            json += "\"link\": \"\(self.link!)\""
        } else {
            json += "\"link\": null"
        }
        
        json += "}"
        
        return json
    }
}