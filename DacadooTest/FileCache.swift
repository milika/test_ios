//
//  FileCache.swift
//  DacadooTest
//
//  Created by Milika Delic on 18.5.24..
//

import Foundation
import UIKit

class FileCache {
    
    static let shared = FileCache()
    
    private let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    private let fileExtension = "dat"
    
    init() {
        removeOldFiles()
    }
    
    private func getTargetUrl(forKey key:String) -> URL {
        return tempDirectoryURL.appendingPathComponent("\(key).\(fileExtension)")
    }
    
    func getData(forKey key: String) -> Data? {
        
        let targetURL = getTargetUrl(forKey: key)
        
        if FileManager.default.fileExists(atPath: targetURL.path) {
            do {
                let data = try Data(contentsOf: targetURL)
                return data
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func saveData(data: Data, forKey key: String) {
        
        let targetURL = getTargetUrl(forKey: key)
        do {
            try data.write(to: targetURL)
        } catch {
            
        }
        
    }
    
    func removeData(forKey key: String) {
        let targetURL = getTargetUrl(forKey: key)
        
        if FileManager.default.fileExists(atPath: targetURL.path) {
            do {
                try FileManager.default.removeItem(at: targetURL)
            } catch {
                
            }
        }
    }
    
    
    private func removeOldFiles() {
        do {
            let items = try FileManager.default.contentsOfDirectory(at: tempDirectoryURL,includingPropertiesForKeys: [.isRegularFileKey,.contentAccessDateKey],options: [.skipsHiddenFiles,.skipsPackageDescendants,.skipsSubdirectoryDescendants])
            
            for item in items {
                if item.pathExtension == fileExtension {
                    do {
                        let fileAttributes = try item.resourceValues(forKeys:[.isRegularFileKey, .contentAccessDateKey])
                        if fileAttributes.isRegularFile ?? false {
                            if fileAttributes.contentAccessDate?.timeIntervalSinceNow ?? 0 < (-10*24*60*60) { // 10 days old
                                try FileManager.default.removeItem(at: item)
                            }
                        }
                    } catch {
                    }
                }
            }
        } catch {
        }
    }
}
