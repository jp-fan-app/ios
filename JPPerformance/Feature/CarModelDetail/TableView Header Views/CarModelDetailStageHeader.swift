//
//  CarModelDetailStageHeader.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


protocol CarModelDetailStageHeaderDelegate: class {

    func carModelDetailStageHeader(_ carModelDetailStageHeader: CarModelDetailStageHeader,
                                   show videos: [JPFanAppClient.YoutubeVideo])

}

class CarModelDetailStageHeader: UITableViewHeaderFooterView {

    @IBOutlet var viewSeperator: UIView!
    @IBOutlet var labelStageName: UILabel!
    @IBOutlet var buttonPlayVideo: UIButton!

    @IBOutlet var viewStageAttributes: UIView!
    @IBOutlet var labelStageAttributePS: UILabel!
    @IBOutlet var labelStageAttributeNM: UILabel!

    weak var delegate: CarModelDetailStageHeaderDelegate?

    private let http = UIApplication.http
    private var youtubeVideos: [JPFanAppClient.YoutubeVideo]?

    override func awakeFromNib() {
        super.awakeFromNib()

        labelStageName.dynamicFont(weight: .heavy, textStyle: .title3)
    }

    func preparePlayButton(for carStage: JPFanAppClient.CarStage) {
        buttonPlayVideo.isHidden = true
        guard let carStageID = carStage.id else { return }

        http.getCarStageVideos(carStageId: carStageID).whenComplete { result in
            let youtubeVideos = (try? result.get()) ?? []
            self.youtubeVideos = youtubeVideos
            DispatchQueue.main.async {
                self.buttonPlayVideo.isHidden = youtubeVideos.count == 0
            }
        }
    }

    @IBAction func actionPlayVideoTouchUpInside(_ sender: UIButton) {
        guard let videos = youtubeVideos else { return }
        delegate?.carModelDetailStageHeader(self, show: videos)
    }

}
