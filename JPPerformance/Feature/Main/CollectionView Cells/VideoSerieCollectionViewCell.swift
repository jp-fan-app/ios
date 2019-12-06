//
//  VideoSerieCollectionViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class VideoSerieCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageViewImage: UIImageView!
    @IBOutlet var labelName: UILabel!

    var videoSerie: JPFanAppClient.VideoSerie? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 20
        layer.masksToBounds = true
    }

    private func updateUI() {
        guard let videoSerie = videoSerie else {
            labelName.text = ""
            imageViewImage.image = nil
            return
        }

        labelName.text = videoSerie.title
//        imageViewLogo.image = ManufacturerLogoMapper.manufacturerLogo(for: manufacturer.name)
    }


}
