import XCTest
import RealmSwift
import CoreLocation
@testable import Sightr

class SightrTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Change Realm Configuration (Tests should not change the data stored in default Realm used by the App)
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreationOfGuides() {
        // *** Check, if inserted ***
        
        // Get previous count
        let cntBefore = SightrModel.defaultModel.guides.count
        
        // Create guide
        let guide = Guide(name: "Test Guide")
        SightrModel.defaultModel.createGuide(guide)
        
        // Get updated count
        let cntAfter = SightrModel.defaultModel.guides.count
        
        XCTAssert((cntBefore + 1) == cntAfter)
        
        // *** Check, if exists ***
        
        let guideByID = SightrModel.defaultModel.guideByID(guide.id)
        XCTAssert(guideByID?.id == guide.id)
    }
    
    func testUpdateOfGuides() {
        // Create guide
        let guide = Guide(name: "Update Guide")
        SightrModel.defaultModel.createGuide(guide)
        
        // Update Guide
        let guideByID = SightrModel.defaultModel.guideByID(guide.id)
        let newName = "Update Guide 2"
        SightrModel.defaultModel.updateGuide(guideByID!, name: newName)
        
        // Check, if update has been successful
        let updated = SightrModel.defaultModel.guideByID(guide.id)
        XCTAssert(updated?.name == newName)
    }
    
    func testRemovalOfGuide() {
        // Create Guide
        let guide = Guide(name: "Removable Guide")
        let id = guide.id
        SightrModel.defaultModel.createGuide(guide)
        
        // Remove Guide
        let idx = SightrModel.defaultModel.indexOfGuide(guide)
        SightrModel.defaultModel.removeGuide(idx!)
        
        // Check, if guide has been removed
        let removedGuide = SightrModel.defaultModel.guideByID(id)
        XCTAssertNil(removedGuide)
    }
    
    func testActivationOfGuide() {
        // Create Guide
        let guide = Guide(name: "Activation Guide")
        SightrModel.defaultModel.createGuide(guide)
        
        // Activate Guide
        let isActivatedBefore = guide.isActivated
        SightrModel.defaultModel.toggleActivationOfGuide(guide.id)
        
        // Check, if not activated
        XCTAssertFalse(isActivatedBefore)
        
        // Get activated Guide
        let activatedGuide = SightrModel.defaultModel.guideByID(guide.id)
        let isActivatedAfter = activatedGuide?.isActivated
        
        // Check, if activated
        XCTAssertTrue(isActivatedAfter!)
        
        // Check, if activation has been toggled
        XCTAssert(isActivatedBefore != isActivatedAfter)
    }
    
    func testPointsOfGuide(){
        
        // ***************** Add Point *****************
        
        // Create Guide
        let guide = Guide(name: "Point Guide")
        SightrModel.defaultModel.createGuide(guide)
        let guideById = SightrModel.defaultModel.guideByID(guide.id)
        
        // Check, if no points are present
        XCTAssert(guideById?.points.count == 0)
        
        // Create and add GuidePoint
        let coord = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        let point = GuidePoint(name: "Testpoint",
                               location: coord,
                               address: "Teststreet 7, 0000 Testville",
                               radius: 250.0,
                               text: "Lorem ipsum",
                               link: "http://www.example.com",
                               imageName: nil)
        
        SightrModel.defaultModel.addPointToGuide(guideById!, point: point, image: nil)
        
        // Check, if point has been added
        let guideWithPoint = SightrModel.defaultModel.guideByID(guideById!.id)
        XCTAssert(guideWithPoint?.points.count == 1)
        
        // ***************** Update Point *****************
        
        // Get created Point
        let pointById = SightrModel.defaultModel.pointByID(guideWithPoint!.id, pointID: point.id)
        
        // Create new Point and make Update
        let newName = "Updated Point"
        let newPoint = GuidePoint(name: newName,
                                  location: coord,
                                  address: "Teststreet 7, 0000 Testville",
                                  radius: 250.0,
                                  text: "Lorem ipsum",
                                  link: "http://www.example.com",
                                  imageName: nil)
        SightrModel.defaultModel.updatePoint(guide, old: pointById!, new: newPoint, image: nil)
        
        // Check, if update has been successful
        let updatedPoint = SightrModel.defaultModel.pointByID(guideWithPoint!.id, pointID: point.id)
        XCTAssert(updatedPoint?.id == pointById?.id && updatedPoint?.name == newName)
        
        // ***************** Remove Point *****************
        
        // Remove Point
        let idx = SightrModel.defaultModel.indexOfPoint(guideWithPoint!, point: updatedPoint!)
        let pointID = updatedPoint!.id
        SightrModel.defaultModel.removePointOfGuide(guideWithPoint!, index: idx!)
        
        // Check, if point is removed
        let removedPoint = SightrModel.defaultModel.pointByID(guideWithPoint!.id, pointID: pointID)
        XCTAssertNil(removedPoint)
        
        // Check, if guide has no points
        let guideWithNoPoints = SightrModel.defaultModel.guideByID(guideWithPoint!.id)
        XCTAssert(guideWithNoPoints?.points.count == 0)
    }
    
    func testHelperMethods() {
        // Create Guide
        let guide = Guide(name: "Point Guide")
        SightrModel.defaultModel.createGuide(guide)
        let guideById = SightrModel.defaultModel.guideByID(guide.id)
        
        // Create and add GuidePoint
        let coord = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        let point = GuidePoint(name: "Testpoint",
                               location: coord,
                               address: "Teststreet 7, 0000 Testville",
                               radius: 250.0,
                               text: "Lorem ipsum",
                               link: "http://www.example.com",
                               imageName: nil)
        
        SightrModel.defaultModel.addPointToGuide(guideById!, point: point, image: nil)
        
        // ***************** Guide Helper *****************
        
        // Get guide indices
        let idxGuideByObj = SightrModel.defaultModel.indexOfGuide(guideById!)
        let idxGuideById = SightrModel.defaultModel.indexOfGuide(guideById!.id)
        let idxGuideNil = SightrModel.defaultModel.indexOfGuide("testtest")
        
        // Check guide indices
        XCTAssertNotNil(idxGuideByObj)
        XCTAssertNotNil(idxGuideById)
        XCTAssertNil(idxGuideNil)
        
        // Get guide objects
        let objGuideById = SightrModel.defaultModel.guideByID(guideById!.id)
        let objGuideNil = SightrModel.defaultModel.guideByID("testtest")
        
        // Check guide objects
        XCTAssertNotNil(objGuideById)
        XCTAssertNil(objGuideNil)
        
        // ***************** Point Helper *****************
        
        // Get point indices
        let idxPointByObj = SightrModel.defaultModel.indexOfPoint(guideById!, point: point)
        let idxPointById = SightrModel.defaultModel.indexOfPoint(guideById!, id: point.id)
        let idxPointNil = SightrModel.defaultModel.indexOfPoint(guideById!, id: "testtest")
        
        // Check point indices
        XCTAssertNotNil(idxPointByObj)
        XCTAssertNotNil(idxPointById)
        XCTAssertNil(idxPointNil)
        
        // Get point objects
        let objPointById = SightrModel.defaultModel.pointByID(guideById!.id, pointID: point.id)
        let objPointNil = SightrModel.defaultModel.pointByID(guideById!.id, pointID: "testtest")
        
        // Check point objects
        XCTAssertNotNil(objPointById)
        XCTAssertNil(objPointNil)
    }
}
