//
//  CarImage.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 11.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient
import ImageSlideshow


@objc class CarImageInputSource: NSObject {

    let http: HTTP
    let carImage: JPFanAppClient.CarImage

    init(carImage: JPFanAppClient.CarImage, http: HTTP) {
        self.http = http
        self.carImage = carImage
    }

}

extension CarImageInputSource: InputSource {

    func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        guard let carImageId = carImage.id else {
            imageView.image = nil
            callback(nil)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.http.getCarImageFile(id: carImageId).whenComplete { result in
                switch result {
                case .success(let imageData):
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        imageView.image = image
                        callback(image)
                    }
                case .failure(let error):
                    print("failed to load image: \(error)")
                }
            }
        }
    }

}
