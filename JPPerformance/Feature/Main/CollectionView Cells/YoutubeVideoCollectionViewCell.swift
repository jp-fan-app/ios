//
//  YoutubeVideoCollectionViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class YoutubeVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageViewImage: UIImageView!
    @IBOutlet var labelName: UILabel!

    let http = HTTP()

    var youtubeVideo: JPFanAppClient.YoutubeVideo? {
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
        guard let youtubeVideo = youtubeVideo else {
            labelName.text = ""
            imageViewImage.image = nil
            return
        }

        labelName.text = youtubeVideo.title
        http.getPublicImage(url: youtubeVideo.thumbnailURL).whenSuccess { image in
            DispatchQueue.main.async {
                self.imageViewImage.image = image
            }
        }
    }

}
