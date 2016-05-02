import UIKit
import CoreData
import GoogleMaps
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    /***********  UTI ***********/
    
    func importFromURL(url:NSURL) -> NSData? {
        let data = NSData(contentsOfURL: url)
        return data
    }
    
    /***********  Geofencing ***********/
    
    func showPointDetails(guideID: String, pointID:String) {
        if let point = SightrModel.defaultModel.pointOfGuide(guideID, pointID: pointID) {
            // Create ViewController instance
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destination:PointDetailsVC = storyboard.instantiateViewControllerWithIdentifier("PointDetails") as! PointDetailsVC
            destination.point = point
            
            let rootViewController = self.window!.rootViewController as! UINavigationController
            
            // Push to destination ViewController
            rootViewController.pushViewController(destination, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Create local notification
        NotificationModel.defaultModel.createNotificationForGuidePoint(region.identifier)
    }
    
    /***********  System related ***********/
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyCYxNbMIjWE2BkIo5Frin3g6dGUuNecbUk")
        
        // Status Bar Appearance
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Navigation Bar Appearance
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.whiteColor()
        navigationBarAppearace.barTintColor = UIColor(red: 84/255, green: 225/255, blue: 214/255, alpha: 1.0)
        navigationBarAppearace.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Geometria-Light", size: 20)!, NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        let alert = UIAlertController(title: notification.alertTitle, message: "You are near a cool sight!", preferredStyle: .Alert)
        
        // Actions
        let dismissAction = UIAlertAction(title: "Got it", style: .Cancel, handler: nil)
        
        let showAction = UIAlertAction(title: "Show me", style: .Default) {
            (action) in
            // Get point and guide id
            let guideID = notification.userInfo!["guideID"] as! String
            let pointID = notification.userInfo!["pointID"] as! String
            
            // Go to point details
            self.showPointDetails(guideID, pointID: pointID)
        }
        
        alert.addAction(dismissAction)
        alert.addAction(showAction)
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let identifier = identifier {
            switch identifier {
            case "GOTIT":
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            case "SHOW":
                // Get point and guide id
                let guideID = notification.userInfo!["guideID"] as! String
                let pointID = notification.userInfo!["pointID"] as! String
                
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                
                // Go to point details
                self.showPointDetails(guideID, pointID: pointID)
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "at.fhooe.mc.hosic.Sightr" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Sightr", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

