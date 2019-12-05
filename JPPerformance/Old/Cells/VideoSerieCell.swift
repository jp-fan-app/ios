//
//  VideoSerieCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 26.10.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit
import Alamofire


class VideoSerieCell: UITableViewCell {

    @IBOutlet weak var imageViewThumbnail: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    private var imageRequest: DataRequest?

    var videoSerie: VideoSerie? {
        didSet {
            guard let videoSerie = videoSerie else {
                imageViewThumbnail.image = nil
                labelTitle.text = ""
                labelDescription.text = ""
                return
            }

            labelTitle.text = videoSerie.title
            let descriptionRows = [
                videoSerie.localizedSerieTimeRangeString(),
                "\(videoSerie.videos.count) Videos"
            ]
            labelDescription.text = descriptionRows.compactMap({ $0 }).joined(separator: "\n")

            // reset old image request
            if let imageRequest = imageRequest {
                imageRequest.cancel()
                self.imageRequest = nil
            }

            if let thumbnailVideo = videoSerie.videoForThumbnail() {
                // reset or check cache
                if let cachedImage = ImageCache.sharedInstance.cachedImageFor(thumbnailVideo.id,
                                                                              type: "video") {
                    imageViewThumbnail.image = cachedImage
                } else {
                    imageViewThumbnail.image = nil
                    activityIndicatorView.startAnimating()
                    if let imageURL = URL(string: thumbnailVideo.thumbnailURL) {
                        imageRequest = Alamofire.request(imageURL)
                        imageRequest?.responseData(completionHandler: { response in
                            guard let data = response.value else { return }
                            guard let image = UIImage(data: data) else { return }
                            self.imageViewThumbnail.image = image
                            self.activityIndicatorView.stopAnimating()
                            self.imageRequest = nil

                            ImageCache.sharedInstance.cacheImage(image, forId: thumbnailVideo.id,
                                                                 type: "video")
                        })
                    }
                }
            } else {
                imageViewThumbnail.image = nil
            }

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.jpDarkGrayColor.withAlphaComponent(0.1)
    }

}
