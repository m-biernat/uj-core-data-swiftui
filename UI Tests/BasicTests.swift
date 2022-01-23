import XCTest

class BasicTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {
    }

    func testCartTab() throws {
        XCUIApplication().tabBars["Tab Bar"].buttons["Koszyk"].tap()
    }
    
    func testAccountTab() throws {
        XCUIApplication().tabBars["Tab Bar"].buttons["Konto"].tap()
    }
    
    func testMapTab() throws {
        XCUIApplication().tabBars["Tab Bar"].buttons["Mapa"].tap()
    }
    
    func testOrderView() throws {
        XCUIApplication().tabBars["Tab Bar"].buttons["Konto"].tap()
        XCUIApplication().buttons["Zamówienia"].tap()
    }
    
    func testMapView() throws {
        let app = XCUIApplication()
        app.tabBars["Tab Bar"].buttons["Mapa"].tap()
        
        let zoomInButton = app.buttons["Zoom In"]
        zoomInButton.tap()
        zoomInButton.tap()
        zoomInButton.tap()
        
        let zoomOutButton = app.buttons["Zoom Out"]
        zoomOutButton.tap()
        zoomOutButton.tap()
        zoomOutButton.tap()
    }
}
