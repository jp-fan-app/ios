//
//  CarModelCollectionViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class CarModelCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageViewMainImage: UIImageView!
    @IBOutlet var imageViewLogo: UIImageView!
    @IBOutlet var labelName: UILabel!

    let http = HTTP()

    var carModel: JPFanAppClient.CarModel? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()

        layer.cornerRadius = 20
        layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        labelName.text = ""
        imageViewLogo.image = nil
        imageViewMainImage.image = nil
    }

    private func updateUI() {
        guard let carModel = carModel else {
            labelName.text = ""
            imageViewLogo.image = nil
            imageViewMainImage.image = nil
            return
        }

        labelName.text = carModel.name
        if let mainImageID = carModel.mainImageID {
            http.getCarImageFile(id: mainImageID).whenSuccess { imageData in
                DispatchQueue.main.async {
                    self.imageViewMainImage.image = UIImage(data: imageData)
                }
            }
        }

        http.getManufacturer(id: carModel.manufacturerID).whenSuccess { manufacturer in
            DispatchQueue.main.async {
                self.imageViewLogo.image = ManufacturerLogoMapper.manufacturerLogo(for: manufacturer.name)
            }
        }
    }

}
