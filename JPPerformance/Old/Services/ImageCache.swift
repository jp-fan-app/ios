//
//  ImageCache.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


//import Foundation
//import UIKit
//import SwiftDate
//
//
//class ImageCache {
//    
//    static let sharedInstance = ImageCache()
//
//    private init() {
//        // remove old cache folder
//        if FileManager.default.fileExists(atPath: oldCacheURL.absoluteString) {
//            try? FileManager.default.removeItem(at: oldCacheURL)
//        }
//    }
//
//    lazy var oldCacheURL: URL = {
//        let documentPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
//        let documentURL = URL(fileURLWithPath: documentPath)
//        let cacheURL = documentURL.appendingPathComponent("image_cache")
//        return cacheURL
//    }()
//
//    lazy var newCacheURL: URL = {
//        let documentPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
//        let documentURL = URL(fileURLWithPath: documentPath)
//        let cacheURL = documentURL.appendingPathComponent("image_cache_1_4_0")
//        if !FileManager.default.fileExists(atPath: cacheURL.absoluteString) {
//            do {
//                try FileManager.default.createDirectory(at: cacheURL,
//                                                        withIntermediateDirectories: true,
//                                                        attributes: nil)
//            } catch { }
//        }
//        return cacheURL
//    }()
//    
//    func cachedImageFor(_ id: Int, type: String) -> UIImage? {
//        guard let cacheFileURL = cacheFileURLFor(imageWithId: id, type: type) else { return nil }
//        guard let cachedImageData = try? Data(contentsOf: cacheFileURL) else { return nil }
//        guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: cacheFileURL.path) else { return nil }
//        guard let fileAge = fileAttributes[FileAttributeKey.creationDate] as? Date else { return nil }
//        let isValid = (fileAge + 7.days) > Date()
//        guard isValid else {
//            try? FileManager.default.removeItem(at: cacheFileURL)
//            return nil
//        }
//        
//        guard let cachedImage = UIImage(data: cachedImageData) else { return nil}
//        return cachedImage
//    }
//
//    func cacheImage(_ image: UIImage, forId id: Int, type: String) {
//        guard let cacheFileURL = cacheFileURLFor(imageWithId: id, type: type) else { return }
//        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
//        do {
//            try imageData.write(to: cacheFileURL)
//        } catch { }
//    }
//    
//    func cacheFileURLFor(imageWithId id: Int, type: String) -> URL? {
//        let cacheFilename = "\(type)_\(id).jpg"
//        return newCacheURL.appendingPathComponent(cacheFilename)
//    }
//
//}
