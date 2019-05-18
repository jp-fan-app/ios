//
//  CarTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import Alamofire


class CarTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewCar: UIImageView?
    @IBOutlet weak var labelModel: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var carItem: JPCarItem? {
        didSet {
            guard let carItem = carItem else {
                imageViewCar?.image = nil
                labelModel.text = ""
                return
            }

            labelModel.text = carItem.model
            labelDescription.text = "\(carItem.stages.count) Stages"

            updateCarImage()
        }
    }

    private func updateCarImage() {
        guard let imageViewCar = imageViewCar else { return }
        guard let carItem = carItem else { return }

        if let mainImage = carItem.mainImage() {
            // reset or check cache
            if let cachedImage = ImageCache.sharedInstance.cachedImageFor(mainImage.id, type: "image") {
                imageViewCar.image = cachedImage
            } else {
                imageViewCar.image = nil
                activityIndicatorView.startAnimating()

                HTTPService.shared.carImageFile(id: mainImage.id) { id, image in
                    guard id == self.carItem?.mainImage()?.id else {
                        print("skip image setting.. replaced by new request")
                        return
                    }
                    imageViewCar.image = image
                    self.activityIndicatorView.stopAnimating()
                    if let image = image {
                        DispatchQueue.global(qos: .background).async {
                            ImageCache.sharedInstance.cacheImage(image, forId: mainImage.id, type: "image")
                        }
                    } else {
                        imageViewCar.image = #imageLiteral(resourceName: "img_no_image")
                    }
                }
            }
        } else {
            imageViewCar.image = #imageLiteral(resourceName: "img_no_image")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.jpDarkGrayColor.withAlphaComponent(0.1)
    }

}
