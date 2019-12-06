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
    @IBOutlet var viewBackground: UIView!

    var manufacturer: JPFanAppClient.ManufacturerModel? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
        updateSelectionStyle()

        layer.cornerRadius = 20
        layer.masksToBounds = true
    }

    override var isSelected: Bool {
        didSet {
            updateSelectionStyle()
        }
    }

    private func updateSelectionStyle() {
        var defaultBackgroundColor = #colorLiteral(red: 0.9493562579, green: 0.9485391974, blue: 0.9704485536, alpha: 1)
        var defaultTextColor = #colorLiteral(red: 0.5572312474, green: 0.5563616753, blue: 0.5783174634, alpha: 1)
        if #available(iOS 13.0, *) {
            defaultBackgroundColor = .secondarySystemBackground
            defaultTextColor = .systemGray
        }

        viewBackground.backgroundColor = isSelected ? .highlightColor1 : defaultBackgroundColor
        imageViewLogo.tintColor = isSelected ? .white : .highlightColor1
        labelName.textColor = isSelected ? .white : defaultTextColor
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
