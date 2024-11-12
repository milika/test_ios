//
//  UnsplashJSONResults.swift
//  DacadooTest
//
//  Created by Milika Delic on 18.5.24..
//

import Foundation

struct UnsplashJSONImageUrls: Codable {
    let raw: String
}

struct UnsplashJSONImageResult: Codable {
    let id: String
    let description: String?
    let alt_description: String?
    let width: Int
    let height: Int
    
    let urls:UnsplashJSONImageUrls
}

struct UnsplashJSONResult: Codable {
    let total_pages: Int
    let total: Int
    let results:[UnsplashJSONImageResult]
}
