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
}
