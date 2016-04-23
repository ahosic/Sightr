import Foundation
class SightrModel {
    
    // Singleton pattern
    class var sharedInstance:SightrModel {
        struct Singleton {
            static let model = SightrModel()
        }
        
        return Singleton.model
    }
    
    var guides = [Guide]()
    
    func createGuide(name:String) {
        // Save Guide
        let guide = Guide(name: name)
        guides.append(guide)
        
        // Get Index of created Guide
        let idx = guides.indexOf({ (currGuide:Guide) in
            if currGuide.id == guide.id {
                return true
            }
            
            return false
        })
        
        let info = ["indices" : [NSIndexPath(forRow: idx!, inSection: 0)]]
        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.GuidesAdded, object: nil, userInfo: info)
    }
    
    func updateGuide(guide:Guide){
        if let idx = indexOfGuide(guide) {
            guides[idx] = guide
            
            let info = ["indices" : [NSIndexPath(forRow: idx, inSection: 0)]]
            NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.GuidesChanged, object: nil, userInfo: info)
        }
    }
    
    func indexOfGuide(guide:Guide) -> Int? {
        let idx = guides.indexOf({(g:Guide) -> Bool in
            if g.id == guide.id {
                return true
            }
            
            return false
        })
        
        return idx;
    }
    
    func indexOfPoint(guide:Guide, point:GuidePoint) -> Int? {
        let idx = guide.points.indexOf({(p:GuidePoint) -> Bool in
            if p.id == point.id {
                return true
            }
            
            return false
        })
        
        return idx
    }
    
    func addPointToGuide(guide:Guide, point:GuidePoint){
        guide.points.append(point)
        
        if let pIdx = indexOfPoint(guide, point: point) {
            updateGuide(guide)
            
            let info = ["guideID" : NSString(string: guide.id) , "indices" : [NSIndexPath(forRow: pIdx, inSection: 0)]]
            NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.PointsAdded, object: nil, userInfo: info)
        }
    }
}