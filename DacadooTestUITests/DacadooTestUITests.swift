//
//  DacadooTestUITests.swift
//  DacadooTestUITests
//
//  Created by Milika Delic on 15.5.24..
//

import XCTest

final class DacadooTestUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    
    func testSearch() {
        // Arrange
        let app = XCUIApplication()
        app.launch()
        let searchText = "dog"
        
        let searchButton = app.buttons["Search"]
        let existenceSearchButton = searchButton.waitForExistence(timeout: 5)
        XCTAssertTrue(existenceSearchButton)
        
        let searchTextField = app.textFields["search_tf"]
        let existencesearchTextField = searchTextField.waitForExistence(timeout: 5)
        XCTAssertTrue(existencesearchTextField)
        
        // Act
        searchButton.tap()
        
        // Assert
        let errorLabel = app.staticTexts["error_lbl"]
        let existenceErrorLabel = errorLabel.waitForExistence(timeout: 5)
        XCTAssertTrue(existenceErrorLabel)
        XCTAssertGreaterThan(errorLabel.label.count, 0)
        
        // Act
        searchTextField.tap()
        searchTextField.typeText(searchText)
        searchButton.tap()
        
        // Assert
        let tableView = app.tables.element(boundBy: 0)
        let existenceTableView = tableView.waitForExistence(timeout: 5)
        XCTAssertTrue(existenceTableView)
        XCTAssertGreaterThan(tableView.cells.count, 0)
        
        // Assert
        let cell = tableView.cells.element(boundBy: 0)
        let existenceCell = cell.waitForExistence(timeout: 5)
        XCTAssertTrue(existenceCell)
        
        // Assert
        let image = cell.images.element(boundBy: 0)
        let existenceImage = image.waitForExistence(timeout: 5)
        XCTAssertTrue(existenceImage)
        while image.frame.size.height < 50 {
            sleep(1)
        }
        
        // Act
        cell.tap()
        
        // Assert
        let closeButton = app.buttons["Close Button"]
        let existenceCloseButton = closeButton.waitForExistence(timeout: 5)
        XCTAssertTrue(existenceCloseButton)
        

    }
}
