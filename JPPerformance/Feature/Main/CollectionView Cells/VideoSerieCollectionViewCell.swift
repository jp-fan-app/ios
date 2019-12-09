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
    let http = HTTP()

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
        imageViewImage.image = nil
        DispatchQueue.global(qos: .userInitiated).async {
            guard let videoSerieId = videoSerie.id else { return }
            self.http.getVideoSerieVideos(videoSerieId: videoSerieId).whenSuccess { youtubeVideos in
                guard let youtubeVideo = youtubeVideos.first else { return }
                self.http.getPublicImage(url: youtubeVideo.thumbnailURL).whenSuccess { image in
                    DispatchQueue.main.async {
                        self.imageViewImage.image = image
                    }
                }
            }
        }

    }


}
