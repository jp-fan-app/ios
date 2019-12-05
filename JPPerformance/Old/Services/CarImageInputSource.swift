//
//  CarImageInputSource.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 23.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


//import Foundation
//import ImageSlideshow
//import Alamofire
//import UIKit
//
//
//class CarImageInputSource {
//
//    let carImage: JPCarImage
//
//    let activityIndicator = UIActivityIndicatorView()
//
//    init(carImage: JPCarImage) {
//        self.carImage = carImage
//    }
//
//}
//
//
//extension CarImageInputSource: InputSource {
//
//    func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
//        if let cachedImage = ImageCache.sharedInstance.cachedImageFor(carImage.id, type: "image") {
//            imageView.image = cachedImage
//            callback(cachedImage)
//        } else {
//            prepareActivityIndicatorFor(view: imageView)
//            HTTPService.shared.carImageFile(id: carImage.id) { id, image in
//                guard id == self.carImage.id else {
//                    print("skip image setting.. replaced by new request")
//                    return
//                }
//                imageView.image = image
//                self.activityIndicator.stopAnimating()
//                if let image = image {
//                    ImageCache.sharedInstance.cacheImage(image, forId: self.carImage.id, type: "image")
//                }
//                callback(image)
//            }
//        }
//    }
//
//    func prepareActivityIndicatorFor(view: UIView) {
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.style = .white
//
//        view.addSubview(activityIndicator)
//        view.addConstraints([
//            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//
//        activityIndicator.startAnimating()
//    }
//
//}
