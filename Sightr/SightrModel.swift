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
            if point.hasImage {
                removeImageFromStorage(point.id)
            }
            
            removedPoints.append(point.id)
        }
        
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
    
    /***********  Guide Points ***********/
    
    func addPointToGuide(guide:Guide, point:GuidePoint){
        // Save to database
        let realm = try! Realm()
        try! realm.write{
            
            // Save image of point
            if point.hasImage {
                saveImageToStorage(point.id, image: point.image!)
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
    
    func updatePoint(guide:Guide, point:GuidePoint, data: GuidePoint){
        if let idx = indexOfPoint(guide, point: point) {
            // Save to database
            let realm = try! Realm()
            try! realm.write {
                point.name = data.name
                
                point.address = data.address
                point.radius = data.radius
                
                point.text = data.text
                point.link = data.link
                
                point.location = data.location
                
                if data.hasImage {
                    point.image = data.image
                    point.hasImage = true
                    saveImageToStorage(point.id, image: data.image!)
                } else {
                    point.image = nil
                    point.hasImage = false
                }
                
                guide.points[idx] = point
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
                removeImageFromStorage(point.id)
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
    
    func pointOfGuide(guideID:String, pointID:String) -> GuidePoint? {
        if let guide = guideByID(guideID) {
            if let pointIndex = indexOfPoint(guide, id: pointID) {
                return guide.points[pointIndex]
            }
        }
        
        return nil
    }
    
    func saveImageToStorage(id:String, image: UIImage) {
        if let img = UIImageJPEGRepresentation(image, 1.0) {
            // Get file path
            let file = getImagesDirectory().stringByAppendingPathComponent(id + ".jpg")
            
            // Write File
            img.writeToFile(file, atomically: true)
        }
    }
    
    func removeImageFromStorage(id:String) {
        // Get file path
        let file = getImagesDirectory().stringByAppendingPathComponent(id + ".jpg")
        do {
            // Remove
            try NSFileManager.defaultManager().removeItemAtPath(file)
        } catch {
            print("Removing image failed.")
        }
    }
    
    func getImagesDirectory() -> NSString {
        // Generate file paths
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDir:AnyObject = paths[0]
        let appDir:AnyObject = documentsDir.stringByAppendingPathComponent("Sightr")
        let imgDir = appDir.stringByAppendingPathComponent("points")
        
        do {
            // Check, if directories already exist
            if !NSFileManager.defaultManager().fileExistsAtPath(imgDir) {
                // Create directories
                try NSFileManager.defaultManager().createDirectoryAtPath(appDir as! String, withIntermediateDirectories: false, attributes: nil)
                try NSFileManager.defaultManager().createDirectoryAtPath(imgDir, withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        return imgDir
    }
}