//
//  PerformanceRowTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class PerformanceRowTableViewCell: UITableViewCell {

    @IBOutlet var viewBackground: UIView!
    @IBOutlet var imageViewBackground: UIImageView!
    @IBOutlet var labelManufacturerName: UILabel!
    @IBOutlet var labelCarModelName: UILabel!
    @IBOutlet var labelStageName: UILabel!
    @IBOutlet var labelPerformanceValue: UILabel!

    let http = HTTP()

    var carModel: JPFanAppClient.CarModel? {
        didSet {
            updateCarModel()
        }
    }

    var carStage: JPFanAppClient.CarStage? {
        didSet {
            updateCarStage()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        clearCarModelValues()
        clearCarStageValues()

        viewBackground.layer.cornerRadius = 17
        viewBackground.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        clearCarModelValues()
        clearCarStageValues()
    }

    private func clearCarModelValues() {
        imageViewBackground.image = nil
        labelCarModelName.text = nil
        labelManufacturerName.text = nil
    }

    private func updateCarModel() {
        guard let carModel = carModel else {
            clearCarModelValues()
            return
        }

        labelCarModelName.text = carModel.name

        DispatchQueue.global(qos: .userInitiated).async {
            self.http.getManufacturer(id: carModel.manufacturerID).whenSuccess { manufacturer in
                DispatchQueue.main.async {
                    self.labelManufacturerName.text = manufacturer.name
                }
            }

            if let mainImageID = carModel.mainImageID {
                self.http.getCarImageFile(id: mainImageID).whenSuccess { imageData in
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.imageViewBackground.image = image
                    }
                }
            }
        }
    }

    private func clearCarStageValues() {
        labelStageName.text = nil
    }

    private func updateCarStage() {
        guard let carStage = carStage else {
            clearCarStageValues()
            return
        }

        labelStageName.text = carStage.name
    }

}
