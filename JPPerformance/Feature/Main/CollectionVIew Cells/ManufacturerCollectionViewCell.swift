//
//  ManufacturerCollectionViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class ManufacturerCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageViewLogo: UIImageView!
    @IBOutlet var labelName: UILabel!

    var manufacturer: JPFanAppClient.ManufacturerModel? {
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

    private func updateUI() {
        guard let manufacturer = manufacturer else {
            labelName.text = ""
            imageViewLogo.image = nil
            return
        }

        labelName.text = manufacturer.name
        imageViewLogo.image = ManufacturerLogoMapper.manufacturerLogo(for: manufacturer.name)
    }

}
