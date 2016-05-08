import Foundation
import RealmSwift

class SightrModel {
    
    // Singleton pattern
    class var defaultModel:SightrModel {
        struct Singleton {
            static let model = SightrModel()
        }
        
        return Singleton.model
    }
    
    var guides = [Guide]()
    
    init() {
        load()
        GeofencingModel.defaultModel.load()
        NotificationModel.defaultModel.setUpNotifications()
    }
    
    func load() {
        let realm = try! Realm()
        let results = realm.objects(Guide)
        guides.appendContentsOf(results)
    }
    
    /***********  Guides ***********/
    
    func createGuide(name:String) {
        // Save Guide
        let guide = Guide(name: name)
        createGuide(guide)
    }
    
    func createGuide(guide:Guide) {
        guides.append(guide)
        
        // Get Index of created Guide
        let idx = guides.indexOf({ (currGuide:Guide) in
            if currGuide.id == guide.id {
                return true
            }
            
            return false
        })
        
        // Save to database
        let realm = try! Realm()
        try! realm.write {
            realm.add(guide)
        }
        
        // Notify observers
        let info = ["operationType" : NSString(string: ModelOperationType.Add), "indices" : [NSIndexPath(forRow: idx!, inSection: 0)]]
        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.GuidesChanged, object: nil, userInfo: info)
    }
    
    func updateGuide(guide:Guide, name:String?) {
        if let idx = indexOfGuide(guide) {
            // Save to database
            let realm = try! Realm()
            try! realm.write {
                
                // Check, if guide name needs to be updated
                if name != nil {
                    guide.name = name!
                }
                
                guides[idx] = guide
                realm.add(guide, update: true)
            }
            
            // Notify observers
            let info = ["operationType" : NSString(string: ModelOperationType.Update), "indices" : [NSIndexPath(forRow: idx, inSection: 0)]]
            NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.GuidesChanged, object: nil, userInfo: info)
        }
    }
    
    func removeGuide(index:Int) {
        // Get guide
        let guide = guides[index]
        
        let guideID = guide.id
        var removedPoints = [NSString]()
        
        // Remove images of points
        for point in guide.points {
            removedPoints.append(point.id)
        }
        
        FileAccessModel.defaultModel.removeGuideFromStorage(guideID)
        guides.removeAtIndex(index)
        
        // Remove from database
        let realm = try! Realm()
        try! realm.write {
            realm.delete(guide)
        }
        
        // Notify observers
        let info = ["operationType" : NSString(string: ModelOperationType.Removed), "indices" : [NSIndexPath(forRow: index, inSection: 0)], "guideID" : NSString(string: guideID), "removedPoints" : removedPoints]
        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.GuidesChanged, object: nil, userInfo: info)
    }
    
    func toggleActivationOfGuide(id:String) {
        let realm = try! Realm()
        try! realm.write {
            if let guide = guideByID(id) {
                guide.isActivated = !guide.isActivated
                
                let idx = indexOfGuide(id)
                var info:[NSObject : AnyObject]?
                
                if guide.isActivated {
                    
                    info = ["operationType" : NSString(string: ModelOperationType.Activated), "indices" : [NSIndexPath(forRow: idx!, inSection: 0)]]
                } else {
                    info = ["operationType" : NSString(string: ModelOperationType.Deactivated), "indices" : [NSIndexPath(forRow: idx!, inSection: 0)]]
                }
                
                // Notify observers
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.GuidesChanged, object: nil, userInfo: info)
            }
        }
    }
    
    /***********  Guide Points ***********/
    
    func addPointToGuide(guide:Guide, point:GuidePoint, image:UIImage?){
        // Save to database
        let realm = try! Realm()
        try! realm.write{
            
            // Save image of point
            if point.hasImage && image != nil {
                FileAccessModel.defaultModel.saveImageToStorage(guide.id, imageName: point.imageName!, image: image!)
            }
            
            guide.points.append(point)
        }
        
        // Update corresponding guide
        if let pIdx = indexOfPoint(guide, point: point) {
            updateGuide(guide, name: nil)
            
            // Notify observers
            let info = ["operationType" : NSString(string: ModelOperationType.Add), "guideID" : NSString(string: guide.id) , "indices" : [NSIndexPath(forRow: pIdx, inSection: 0)]]
            NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.PointsChanged, object: nil, userInfo: info)
        }
    }
    
    func updatePoint(guide:Guide, old:GuidePoint, new: GuidePoint, image:UIImage?){
        if let idx = indexOfPoint(guide, point: old) {
            // Save to database
            let realm = try! Realm()
            try! realm.write {
                old.name = new.name
                
                old.address = new.address
                old.radius = new.radius
                
                old.text = new.text
                old.link = new.link
                
                old.location = new.location
                
                if new.hasImage && image != nil {
                    
                    if old.imageName == nil {
                        old.imageName = new.imageName
                    }
                    
                    old.hasImage = true
                    FileAccessModel.defaultModel.saveImageToStorage(guide.id, imageName: old.imageName! , image: image!)
                } else {
                    old.imageName = nil
                    old.hasImage = false
                }
                
                guide.points[idx] = old
            }
            
            // Update corresponding guide
            updateGuide(guide, name: nil)
            
            // Notify observers
            let info = ["operationType" : NSString(string: ModelOperationType.Update), "guideID" : NSString(string: guide.id) , "indices" : [NSIndexPath(forRow: idx, inSection: 0)]]
            NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.PointsChanged, object: nil, userInfo: info)
        }
    }
    
    func removePointOfGuide(guide:Guide, index:Int) {
        let point = guide.points[index]
        let pointID = point.id
        
        // Remove from database
        let realm = try! Realm()
        try! realm.write {
            // Remove image from storage
            if point.hasImage {
                FileAccessModel.defaultModel.removeImageFromStorage(guide.id, imageName: point.imageName!)
            }
            
            // Remove point
            guide.points.removeAtIndex(index)
            realm.delete(point)
        }
        
        // Update corresponding guide
        updateGuide(guide, name: nil)
        
        // Notify observers
        let info = ["operationType" : NSString(string: ModelOperationType.Removed), "guideID" : NSString(string: guide.id), "pointID" : NSString(string: pointID), "indices" : [NSIndexPath(forRow: index, inSection: 0)]]
        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotification.PointsChanged, object: nil, userInfo: info)
    }
    
    /***********  Helper methods ***********/
    
    func indexOfGuide(guide:Guide) -> Int? {
        let idx = guides.indexOf({(g:Guide) -> Bool in
            if g.id == guide.id {
                return true
            }
            
            return false
        })
        
        return idx;
    }
    
    func indexOfGuide(id:String) -> Int? {
        let idx = guides.indexOf({(g:Guide) -> Bool in
            if g.id == id {
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
    
    func indexOfPoint(guide:Guide, id:String) -> Int? {
        let idx = guide.points.indexOf({(point:GuidePoint) -> Bool in
            if point.id == id {
                return true
            }
            
            return false
        })
        
        return idx
    }
    
    func guideByID(id:String) -> Guide? {
        if let index = indexOfGuide(id) {
            return guides[index]
        }
        
        return nil
    }
    
    func pointByID(guideID:String, pointID:String) -> GuidePoint? {
        if let guide = guideByID(guideID) {
            if let pointIndex = indexOfPoint(guide, id: pointID) {
                return guide.points[pointIndex]
            }
        }
        
        return nil
    }
}