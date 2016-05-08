import Foundation
import RealmSwift
import SwiftyJSON

class Guide : Object {
    dynamic var id:String = ""
    dynamic var name:String = ""
    dynamic var isActivated:Bool = false
    dynamic var timestamp:NSDate = NSDate()
    var formattedTimeStamp:String {
        get {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            
            return formatter.stringFromDate(timestamp)
        }
    }
    let points = List<GuidePoint>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name:String){
        self.init()
        
        self.id = NSUUID().UUIDString
        self.name = name
        self.isActivated = false
        self.timestamp = NSDate()
    }
    
    convenience init(data:NSData) {
        self.init()
        
        let json = JSON(data: data)
        
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.isActivated = json["isActivated"].boolValue
        
        let dateFormatter = NSDateFormatter()
        if let time = dateFormatter.dateFromString(json["timestamp"].stringValue) {
            self.timestamp = time
        } else {
            self.timestamp = NSDate()
        }
        
        let jsonPoints = json["points"].arrayValue
        for jsonPoint in jsonPoints {
            let point = GuidePoint(json: jsonPoint)
            points.append(point)
        }
    }
    
    func toJSON() -> String {
        let guideID = NSUUID().UUIDString
        
        var json = "{"
        
        json += "\"id\": \"\(guideID)\","
        json += "\"name\": \"\(self.name)\","
        json += "\"isActivated\": \"\(false)\","
        json += "\"timestamp\": \"\(self.timestamp)\","
        json += "\"points\": ["
        
        var firstPoint:Bool = true
        for point in self.points {
            if !firstPoint {
                json += ","
            }
            
            json += point.toJSON()
            firstPoint = false
        }
        
        json += "]}"
        
        return json
    }
}