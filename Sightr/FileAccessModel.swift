import Foundation
import UIKit
import SSZipArchive

class FileAccessModel {
    
    // Singleton pattern
    class var defaultModel:FileAccessModel {
        struct Singleton {
            static let model = FileAccessModel()
        }
        
        return Singleton.model
    }
    
    let fileExtension = ".sightr"
    let dataFileName = "data.json"
    
    /*********** Serialization methods ***********/
    
    func serializeGuide(guide:Guide) -> NSURL?{
        // Serialize guide
        let json = guide.toJSON()
        
        // Get path
        let guideDir = FileAccessModel.defaultModel.getGuideDirectory(guide.id)
        let dataPath:AnyObject = guideDir.stringByAppendingPathComponent(dataFileName)
        let zipPath:AnyObject = FileAccessModel.defaultModel.getShareDirectory().stringByAppendingPathComponent(guide.id + fileExtension)
        
        do {
            // Remove existing JSON file
            removeFileOrDirectory(dataPath as! String)
            
            // Write file
            try json.writeToFile(dataPath as! String, atomically: true, encoding: NSUTF8StringEncoding)
            
            // Zip content of guide
            SSZipArchive.createZipFileAtPath(zipPath as! String, withContentsOfDirectory: guideDir as! String)
            
            // Remove JSON file
            removeFileOrDirectory(dataPath as! String)
        }catch {
            print("Preparing for sharing failed.")
        }
        
        return NSURL(fileURLWithPath: zipPath as! String)
    }
    
    func deserializeGuide(url:NSURL) {
        // Check, if file exists
        if let zipPath = url.path {
            if NSFileManager.defaultManager().fileExistsAtPath(zipPath) {
                let guidesDir:AnyObject = getOrCreateDirectory(getDocumentsDirectory().stringByAppendingPathComponent("guides"))
                
                // Extract filename
                let fileName = (url.absoluteString as NSString).lastPathComponent
                let fileNameArr = fileName.characters.split(".").map(String.init)
                
                // Get temporary directory
                let temp:AnyObject = getTemporaryDirectory().stringByAppendingPathComponent(fileNameArr[0])
                //let tempDir = getOrCreateDirectory(temp)
                
                // Unzip archive
                SSZipArchive.unzipFileAtPath(zipPath, toDestination: temp as! String, progressHandler: nil){
                    (text, status, error) in
                    // When completed
                    
                    let dataPath = temp.stringByAppendingPathComponent(self.dataFileName)
                    if let data = NSData(contentsOfFile: dataPath){
                        // Create Object from JSON
                        let guide = Guide(data: data)
                        
                        let guideDir:AnyObject = self.getOrCreateDirectory(guidesDir.stringByAppendingPathComponent(guide.id))
                        
                        // Move content of guide to destination
                        for point in guide.points {
                            if point.hasImage && point.imageName != nil {
                                // Generate paths
                                let srcPath:AnyObject = temp.stringByAppendingPathComponent((point.imageName)!)
                                let destPath:AnyObject  = guideDir.stringByAppendingPathComponent((point.imageName)!)
                                
                                
                                // Move file
                                self.moveFile(srcPath, to: destPath)
                            }
                        }
                        
                        // Remove temporary directory
                        self.removeFileOrDirectory(temp as! String)
                        
                        // Remove Zip Archive
                        self.removeFileOrDirectory(zipPath)
                        
                        // Persist object
                        SightrModel.defaultModel.createGuide(guide)
                    }
                }
            }
        }
    }
    
    /*********** File Operation methods ***********/
    
    func saveImageToStorage(guideID:String, imageName:String, image: UIImage) {
        if let img = UIImageJPEGRepresentation(image, 1.0) {
            // Get file path
            let file = getGuideDirectory(guideID).stringByAppendingPathComponent(imageName)
            
            // Write File
            img.writeToFile(file, atomically: true)
        }
    }
    
    func moveFile(from:AnyObject, to:AnyObject) {
        do {
            if NSFileManager.defaultManager().fileExistsAtPath(from as! String) {
                try NSFileManager.defaultManager().moveItemAtPath(from as! String, toPath: to as! String)
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func removeImageFromStorage(guideID:String, imageName:String) {
        let file = getGuideDirectory(guideID).stringByAppendingPathComponent(imageName)
        removeFileOrDirectory(file as String)
    }
    
    func removeGuideFromStorage(guideID:String) {
        let file = getGuideDirectory(guideID)
        removeFileOrDirectory(file as! String)
    }
    
    func removeFileOrDirectory(path:String) {
        do {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    func getImageForPoint(guideID:String, imageName:String) -> UIImage? {
        let path = getGuideDirectory(guideID).stringByAppendingPathComponent(imageName)
        let image = UIImage(contentsOfFile: path as String)
        return image
    }
    
    /*********** Getting directories ***********/
    
    func getOrCreateDirectory(dir:AnyObject) -> AnyObject{
        do {
            // Check, if directories already exist
            if !NSFileManager.defaultManager().fileExistsAtPath(dir as! String) {
                // Create directories
                try NSFileManager.defaultManager().createDirectoryAtPath(dir as! String, withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        return dir
    }
    
    func getTemporaryDirectory() -> AnyObject{
        let tempDir = getDocumentsDirectory().stringByAppendingPathComponent("temp")
        let dir = getOrCreateDirectory(tempDir)
        return dir
    }
    
    func getShareDirectory() -> AnyObject {
        let shareDir:AnyObject = getDocumentsDirectory().stringByAppendingPathComponent("share")
        let dir = getOrCreateDirectory(shareDir)
        return dir
    }
    
    func getDocumentsDirectory() -> AnyObject {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDir:AnyObject = paths[0]
        return documentsDir
    }
    
    func getGuideDirectory(guideID:String) -> AnyObject {
        let appDir:AnyObject = getDocumentsDirectory().stringByAppendingPathComponent("guides")
        let guideDir = getOrCreateDirectory(appDir).stringByAppendingPathComponent(guideID)
        
        let dir = getOrCreateDirectory(guideDir)
        return dir
    }
}