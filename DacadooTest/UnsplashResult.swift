//
//  UnsplashResult.swift
//  DacadooTest
//
//  Created by Milika Delic on 17.5.24..
//

import Foundation
import UIKit

class UnsplashResult:NSObject {
    var searchText:String
    
    var totalPages:Int
    var total:Int
    var currentPage:Int
    
    var images:[UnsplashImageResult]
    
    private let resizeQueue = DispatchQueue(label: "resize.serial.queue", qos: .background,
                                            attributes: [],
                                            autoreleaseFrequency: .inherit,
                                            target: nil)
    
    override init() {
        
        searchText = ""
        
        totalPages = 0
        total = 0
        currentPage = 0
        
        images = []
        
    }
    
    func clear() {
        searchText = ""
        
        totalPages = 0
        total = 0
        currentPage = 0
        
        images = []
    }
    
    func getImageResized(_ index:Int) -> UIImage? {
        if index < images.count {
            return images[index].imageResized
        } else {
            return nil
        }
    }
    
    func getImage(_ index:Int) -> UnsplashImageResult? {
        if index < images.count {
            return images[index]
        } else {
            return nil
        }
    }
    
    func setImageData(index:Int, data:Data, completion: @escaping (Bool)->()) {
        if images.count > index {
            images[index].imageData = data
            images[index].loadImage()
            if images[index].image != nil {
                resizeQueue.async {
                    if self.images.count > index {
                        self.images[index].createResizedImage()
                        if self.images.count > index {
                            self.images[index].image = nil
                            completion(true)
                        }
                    }
                }
            } else {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
}

class UnsplashImageResult:NSObject {
    var downloadURL:String = ""
    var id:String = ""
    var image:UIImage?
    var imageResized:UIImage?
    var imageData:Data?
    var downloadRetry = 0
    var imageDescription = ""
    
    func loadImage() {
        if image == nil {
            if let imageData = imageData {
                image = UIImage(data: imageData)
            }
        }
    }
    
    func createResizedImage() {
        imageResized = nil
        if let sourceImage = image {
            let oldWidth = sourceImage.size.width
            let scaleFactor = 300.0 / oldWidth
            
            let newHeight = sourceImage.size.height * scaleFactor
            let newWidth = oldWidth * scaleFactor
            
            let size = CGSize(width:newWidth, height:newHeight)
            
            imageResized = UIGraphicsImageRenderer(size: size).image { _ in
                sourceImage.draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }
}
