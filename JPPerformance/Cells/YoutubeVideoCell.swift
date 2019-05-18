//
//  YoutubeVideoCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import Alamofire


class YoutubeVideoCell: UITableViewCell {

    @IBOutlet weak var imageViewThumbnail: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    private var imageRequest: DataRequest?

    var video: YoutubeVideoModel? {
        didSet {
            guard let video = video else {
                imageViewThumbnail.image = nil
                labelTitle.text = ""
                labelDescription.text = ""
                return
            }

            labelTitle.text = video.title
            labelDescription.text = video.videoDescription

            // reset old image request
            if let imageRequest = imageRequest {
                imageRequest.cancel()
                self.imageRequest = nil
            }

            // reset or check cache
            if let cachedImage = ImageCache.sharedInstance.cachedImageFor(video.id, type: "video") {
                imageViewThumbnail.image = cachedImage
            } else {
                imageViewThumbnail.image = nil
                activityIndicatorView.startAnimating()
                if let imageURL = URL(string: video.thumbnailURL) {
                    imageRequest = Alamofire.request(imageURL)
                    imageRequest?.responseData(completionHandler: { response in
                        guard let data = response.value else { return }
                        guard let image = UIImage(data: data) else { return }
                        self.imageViewThumbnail.image = image
                        self.activityIndicatorView.stopAnimating()
                        self.imageRequest = nil

                        ImageCache.sharedInstance.cacheImage(image, forId: video.id, type: "video")
                    })
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.jpDarkGrayColor.withAlphaComponent(0.1)
    }

}
