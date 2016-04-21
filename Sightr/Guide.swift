import Foundation

class Guide {
    var id:String
    var name:String
    var timestamp:NSDate
    var formattedTimeStamp:String {
        get {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            
            return formatter.stringFromDate(timestamp)
        }
    }
    var points = [GuidePoint]()
    
    init(name:String){
        self.id = NSUUID().UUIDString
        self.name = name
        self.timestamp = NSDate()
    }
}