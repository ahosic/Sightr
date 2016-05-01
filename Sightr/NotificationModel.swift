import Foundation
import UIKit

class NotificationModel {
    // Singleton pattern
    class var defaultModel:NotificationModel {
        struct Singleton {
            static let model = NotificationModel()
        }
        
        return Singleton.model
    }
    
    let notificationCategory:String = "GEOFENCE_CATEGORY"
    
    func setUpNotifications() {
        // Action: Dismiss notification
        let got = UIMutableUserNotificationAction()
        got.identifier = "GOTIT"
        got.title = "Got it"
        got.activationMode = UIUserNotificationActivationMode.Background
        got.authenticationRequired = false
        got.destructive = false
        
        // Action: Show guide point
        let show = UIMutableUserNotificationAction()
        show.identifier = "SHOW"
        show.title = "Show"
        show.activationMode = UIUserNotificationActivationMode.Foreground
        show.authenticationRequired = true
        show.destructive = false
        
        // Notification Category
        let geofenceCategory = UIMutableUserNotificationCategory()
        geofenceCategory.identifier = notificationCategory
        
        geofenceCategory.setActions([show, got], forContext: .Default)
        geofenceCategory.setActions([show, got], forContext: .Minimal)
        
        // Create and register notification settings
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: [geofenceCategory])
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func createNotificationForGuidePoint(id:String) {
        let idArr = id.characters.split(";").map(String.init)
        let guideID = idArr[0]
        let pointID = idArr[1]
        
        if let guide = SightrModel.defaultModel.guideByID(guideID) {
            if let point = SightrModel.defaultModel.pointOfGuide(guideID, pointID: pointID) {
                
                // Create local notification
                let notification = UILocalNotification()
                notification.alertTitle = guide.name
                notification.alertBody = point.name
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = 1
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.fireDate = NSDate()
                notification.category = notificationCategory
                notification.userInfo = ["guideID" : guideID, "pointID" : pointID]
                
                // Show not more than 3 notifications
                if UIApplication.sharedApplication().scheduledLocalNotifications?.count > 3 {
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
                }
                
                // Schedule notification
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
    }
}