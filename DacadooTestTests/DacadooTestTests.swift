//
//  DacadooTestTests.swift
//  DacadooTestTests
//
//  Created by Milika Delic on 15.5.24..
//

import XCTest
@testable import DacadooTest

final class DacadooTestTests: XCTestCase, NetworkingDelegate {
    
    let mockNetworking = MockNetworking()
    

    // NetworkingDelegate
    var pageLoadExpectation: XCTestExpectation?
    var pageLoadExpectation2: XCTestExpectation?
    
    var updatedImageExpectation: XCTestExpectation?
    
    var errorExpectation: XCTestExpectation?
    
    func updatedImage(index: Int) {
        updatedImageExpectation?.fulfill()
    }
    
    func pageLoaded() {
        pageLoadExpectation?.fulfill()
        pageLoadExpectation2?.fulfill()
    }
    
    func errorHandle(error: any Error) {
        errorExpectation?.fulfill()
    }
   
  
    
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    
    func testSearchSucced()  {
        // Arrange
        let searchText = "dog"
        pageLoadExpectation = expectation(description: "Searching for \(searchText)")
        pageLoadExpectation2 = nil
        mockNetworking.delegate = self
        mockNetworking.searchShouldSucceed = true
        
        // Act
        mockNetworking.search(searchText)
        
        // Assert
        waitForExpectations(timeout: 3)
        pageLoadExpectation = nil
        
        XCTAssertEqual(mockNetworking.result.searchText, searchText,"Search text must be remembered")
        XCTAssertGreaterThan(mockNetworking.result.total, 0,"Some results must be present")
        XCTAssertGreaterThan(mockNetworking.result.images.count, 0,"Some results images must be present")
        
        // Arrange
        let oldCount = mockNetworking.result.images.count
        pageLoadExpectation2 = expectation(description: "Searching for \(searchText) page 2")
        
        // Act
        mockNetworking.loadNextPage()
        
        // Assert
        waitForExpectations(timeout: 3)
        XCTAssertGreaterThan(mockNetworking.result.images.count, oldCount, "New results images must be present")
    }
    
    func testSearchFail()  {
        // Arrange
        let searchText = "dog"
        pageLoadExpectation = expectation(description: "Searching for \(searchText)")
        pageLoadExpectation?.isInverted = true
        pageLoadExpectation2 = nil
        mockNetworking.delegate = self
        mockNetworking.searchShouldSucceed = false
        
        // Act
        mockNetworking.search(searchText)
        
        // Assert
        waitForExpectations(timeout: 3)
        pageLoadExpectation = nil
        
    
    }
    
    func testImageDownloadSucced()  {
        // Arrange
        let searchText = "dog"
        pageLoadExpectation = expectation(description: "Searching for \(searchText)")
        pageLoadExpectation2 = nil
        mockNetworking.delegate = self
        mockNetworking.searchShouldSucceed = true
        
        // Act
        mockNetworking.search(searchText)
        
        // Assert
        waitForExpectations(timeout: 3)
        pageLoadExpectation = nil
        
        // Arrange
        updatedImageExpectation = expectation(description: "Downloading image")
        mockNetworking.downloadShouldSucceed = true
        
        // Act
        mockNetworking.downloadImage(0)
  
        // Assert
        waitForExpectations(timeout: 3)
        updatedImageExpectation = nil
        
    }
    
    
    func testImageDownloadFail()  {
        // Arrange
        let searchText = "dog"
        pageLoadExpectation = expectation(description: "Searching for \(searchText)")
        pageLoadExpectation2 = nil
        mockNetworking.delegate = self
        mockNetworking.searchShouldSucceed = true
        
        // Act
        mockNetworking.search(searchText)
        
        // Assert
        waitForExpectations(timeout: 3)
        pageLoadExpectation = nil
        
        // Arrange
        updatedImageExpectation = expectation(description: "Downloading image")
        updatedImageExpectation?.isInverted = true
        mockNetworking.downloadShouldSucceed = false
        
        // Act
        mockNetworking.downloadImage(0)
  
        // Assert
        waitForExpectations(timeout: 3)
        updatedImageExpectation = nil
        
    }
   
    
    func testFileCache()  {
        // Arrange
        let fileKey = "test"
        let data = Data(fileKey.utf8)
        
        // Act
        FileCache.shared.removeData(forKey: fileKey)
        let dataEmpty = FileCache.shared.getData(forKey: fileKey)
       
        // Assert
        XCTAssertNil(dataEmpty)
        
        // Act
        FileCache.shared.saveData(data: data, forKey: fileKey)
        let dataFilled = FileCache.shared.getData(forKey: fileKey)
        
        // Assert
        XCTAssertEqual(data, dataFilled)
        
        // Act
        FileCache.shared.removeData(forKey: fileKey)
        let dataEmpty2 = FileCache.shared.getData(forKey: fileKey)
        
        // Assert
        XCTAssertNil(dataEmpty2)
       
    }
    
    
}
