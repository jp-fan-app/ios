//
//  Cache+PublicImage.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    func store(publicImageURL: String, image: Image) {
        guard let key = publicImageURL.data(using: .utf8)?.base64EncodedString() else { return }
        try? publicImagesStorage.setObject(image, forKey: key)
    }

    func cached(publicImageURL: String) -> Image? {
        guard let key = publicImageURL.data(using: .utf8)?.base64EncodedString() else { return nil }
        return try? publicImagesStorage.object(forKey: key)
    }

}
