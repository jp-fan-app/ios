//
//  YoutubePlayerVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 09.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient
import YouTubePlayer


class YoutubePlayerVC: UIViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }

    @IBOutlet var youtubePlayerView: YouTubePlayerView!
    @IBOutlet var buttonClose: UIButton!

    var youtubeVideo: JPFanAppClient.YoutubeVideo? {
        didSet {
            loadYoutubeVideo()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        youtubePlayerView.delegate = self
        buttonClose.layer.cornerRadius = buttonClose.frame.size.width / 2.0
        buttonClose.layer.masksToBounds = true

        loadYoutubeVideo()
    }

    @IBAction func actionCloseTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    private func loadYoutubeVideo() {
        guard isViewLoaded else { return }
        guard let youtubeVideo = youtubeVideo else { return }
        youtubePlayerView.loadVideoID(youtubeVideo.videoID)
    }

}

extension YoutubePlayerVC: YouTubePlayerDelegate {

    func playerReady(_ videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
    }

}
