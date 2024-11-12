//
//  Networking.swift
//  DacadooTest
//
//  Created by Milika Delic on 16.5.24..
//

import Foundation
import UIKit


protocol NetworkingDelegate {
    func updatedImage(index:Int)
    func pageLoaded()
    func errorHandle(error:Error)
}

class NetworkingBase {
    var delegate:NetworkingDelegate? = nil
    var searchInProgress:Bool = false
    
    var result:UnsplashResult! = UnsplashResult()
    
    func search(_ text:String) {
        result = UnsplashResult()
        result.searchText = text
        searchPage(text, page: 1)
    }
    func loadNextPage() {
        if result.currentPage >= 1, !searchInProgress {
            if result.currentPage < result.totalPages {
                searchPage(result.searchText, page: result.currentPage+1)
            }
        }
    }
    
    func searchPage(_ text:String, page:Int) {
    }
    
    func downloadImage(_ index:Int) {
        
    }
}


class Networking:NetworkingBase {
    
    static let shared = Networking()
    
    static let errorDomain = "UNSPLASH_ERROR"
    static let errorInfoKey = "info"
    
    private var session = URLSession.shared
    
    private let key = "NHr5nmnvy4fJA0AtfpReQm_EI2SBnnvPajDObRtmYbY"
    
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
        
    }
    
    override func searchPage(_ text:String, page:Int) {
        if let url = URL(string: "https://api.unsplash.com/search/photos?query=\(text)&page=\(page)&client_id=\(key)") {
            searchInProgress = true
            let task = session.dataTask(with: url) {(data, response, error) in
                self.searchInProgress = false
                
                if let error = error {
                    self.delegate?.errorHandle(error: error)
                    return
                }
                
                if let data = data {
                    
                  
                    
                    let decoder = JSONDecoder()
                    do {
                        let jsonResult = try decoder.decode(UnsplashJSONResult.self, from: data)
                        
                        if jsonResult.total == 0 {
                            let error = NSError(domain: Networking.errorDomain, code: 11, userInfo: [Networking.errorInfoKey:"No results!"])
                            self.delegate?.errorHandle(error: error)
                        } else {
                            self.result.currentPage = page
                            self.result.total = jsonResult.total
                            self.result.totalPages = jsonResult.total_pages
                            
                            for imageJsonResult in jsonResult.results {
                                let imageResut = UnsplashImageResult()
                                imageResut.id = imageJsonResult.id
                                if let imageDescription = imageJsonResult.description {
                                    imageResut.imageDescription = imageDescription
                                } else if let imageDescription = imageJsonResult.alt_description {
                                    imageResut.imageDescription = imageDescription
                                }
                                imageResut.downloadURL = imageJsonResult.urls.raw
                                self.result.images.append(imageResut)
                                self.downloadImage(self.result.images.count-1)
                            }
                            
                            self.delegate?.pageLoaded()
                        }
                    } catch let error {
                        if let string = String(data: data, encoding: .utf8) {
                            let error = NSError(domain: Networking.errorDomain, code: 13, userInfo: [Networking.errorInfoKey:"JSON Decode Error: \(string)"])
                        } else {
                            self.delegate?.errorHandle(error: error)
                        }
                    }
                } else {
                    let error = NSError(domain: Networking.errorDomain, code: 10, userInfo: [Networking.errorInfoKey:"No data present!"])
                    self.delegate?.errorHandle(error: error)
                }
                
            }
            task.resume()
        }
    }
    
    override func downloadImage(_ index:Int) {
        if result.images.count > index {
            if let data = FileCache.shared.getData(forKey: result.images[index].id) {
                self.result.setImageData(index: index, data: data) { success in
                    if success {
                        self.delegate?.updatedImage(index: index)
                    } else {
                        FileCache.shared.removeData(forKey: self.result.images[index].id)
                        self.downloadImage(index)
                    }
                }
            } else if result.images[index].downloadRetry < 3 {
                if let url = URL(string: result.images[index].downloadURL) {
                    let task = session.dataTask(with: url) {(data, response, error) in
                        if let data = data {
                            self.result.setImageData(index: index, data: data) { success in
                                if self.result.images.count > index {
                                    if success {
                                        FileCache.shared.saveData(data: data, forKey: self.result.images[index].id)
                                        self.delegate?.updatedImage(index: index)
                                    } else {
                                        self.result.images[index].downloadRetry += 1
                                        self.downloadImage(index)
                                    }
                                }
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    
}
