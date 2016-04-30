import Foundation
import RealmSwift

class Guide : Object {
    dynamic var id:String = ""
    dynamic var name:String = ""
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
        self.timestamp = NSDate()
    }
}