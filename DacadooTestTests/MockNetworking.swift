//
//  MockNetworking.swift
//  DacadooTestTests
//
//  Created by Milika Delic on 21.5.24..
//

import XCTest
@testable import DacadooTest

class MockNetworking: NetworkingBase {
    var downloadShouldSucceed:Bool = true
    var searchShouldSucceed:Bool = true
    
    
    override func searchPage(_ text:String, page:Int) {
        
        searchInProgress = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.searchInProgress = false
            
            if self.searchShouldSucceed {
                self.result.currentPage = page
                self.result.total = 20
                self.result.totalPages = 2
                
                for index in 1...10 {
                    let imageResut = UnsplashImageResult()
                    imageResut.id = "\(index)"
                    imageResut.downloadURL = "?"
                    self.result.images.append(imageResut)
                }
                
                self.delegate?.pageLoaded()
            } else {
                let error = NSError(domain: Networking.errorDomain, code: 12, userInfo: [Networking.errorInfoKey:"Simulated Error"])
                self.delegate?.errorHandle(error: error)
            }
            
        }
        
    }
    
    override func downloadImage(_ index:Int) {
        if self.downloadShouldSucceed {
            DispatchQueue.global(qos: .userInitiated).async {
                self.delegate?.updatedImage(index: index)
            }
        }
    }
    
    
    
}
