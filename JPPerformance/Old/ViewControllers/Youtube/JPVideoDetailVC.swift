//
//  JPVideoDetailVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import YouTubePlayer
import Alamofire
import GoogleMobileAds


class JPVideoDetailVC: JPBaseViewController {

    var video: YoutubeVideoModel?
    var videoDetail: JPYoutubeVideoDetail?

    // MARK: - Outlets

    // MARK: Video Header

    @IBOutlet weak var youtubePlayerView: YouTubePlayerView!
    @IBOutlet weak var labelVideoTitleAboveVideo: UILabel!
    @IBOutlet weak var activityIndicatorVideo: UIActivityIndicatorView!
    @IBOutlet weak var imageViewVideoThumbnail: UIImageView!
    private var firstTimePlayingTheVideo = true

    // MARK: Video Infos

    @IBOutlet weak var labelVideoDescription: UILabel!

    @IBOutlet weak var stackViewVideoCounts: UIStackView!
    @IBOutlet weak var labelVideoViewCount: TagLabel!
    @IBOutlet weak var labelVideoLikeCount: TagLabel!
    @IBOutlet weak var labelVideoDisikeCount: TagLabel!
    @IBOutlet weak var labelVideoCommentCount: TagLabel!

    @IBOutlet var lcLabelVIdeoDescriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonMore: UIButton!
    private var isVideoDescriptionCollapsed: Bool = true

    @IBOutlet weak var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if ProcessInfo.processInfo.arguments.contains("TAKING_SCREENSHOTS") {
            bannerView.isHidden = true
        }

        buttonMore.setTitle("more".localized(), for: .normal)

        // adjust tag labels for smaller devices
        if UIScreen.main.bounds.size.width == 320.0 {
            for label in [labelVideoViewCount, labelVideoLikeCount, labelVideoDisikeCount, labelVideoCommentCount] {
                label?.font = label?.font.withSize(10)
            }
        }

        loadVideoInformation()
        loadVideoDetailInformations()
        preparePlayerWithSearchResultItem()

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerVideoDetail()
        bannerView.rootViewController = self
        bannerView.load(AdMobService.sharedService.request())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fixInterfaceOrientationIfNeeded),
                                               name: UIWindow.didBecomeHiddenNotification,
                                               object: view.window)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self,
                                                  name: UIWindow.didBecomeHiddenNotification,
                                                  object: view.window)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        let isOnStack = navigationController?.viewControllers.contains(self) ?? false
        if !isOnStack {
            bannerView.removeFromSuperview()
            video = nil
            youtubePlayerView.removeFromSuperview()
            youtubePlayerView = nil
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    func loadVideoInformation() {
        guard let video = video else { return }
        guard let imageURL = URL(string: video.thumbnailURL) else { return }

        labelVideoTitleAboveVideo.text = video.title
        labelVideoDescription.text = video.videoDescription

        Alamofire.request(imageURL).responseData(completionHandler: { [weak self] response in
            guard let data = response.value else { return }
            guard let image = UIImage(data: data) else { return }

            self?.imageViewVideoThumbnail.image = image
        })
    }

    func loadVideoDetailInformations() {
        stackViewVideoCounts.isHidden = true
        guard let video = video else { return }

        if let videoDetail = videoDetail {
            updateVideoDetailInformationUIFromVideoDetail(videoDetail)
        } else {
            YoutubeService.shared.fetchVideoDetails(forYoutubeID: video.videoID) { [weak self] detail in
                self?.videoDetail = detail
                guard let detail = detail else { return }
                self?.updateVideoDetailInformationUIFromVideoDetail(detail)
            }
        }
    }

    private func updateVideoDetailInformationUIFromVideoDetail(_ detail: JPYoutubeVideoDetail) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.labelVideoDescription.text = detail.description
            self.labelVideoViewCount.text = "\(detail.viewCount.formattedWithSeparator) 👀"
            self.labelVideoLikeCount.text = "\(detail.likeCount.formattedWithSeparator) 👍🏼"
            self.labelVideoDisikeCount.text = "\(detail.dislikeCout.formattedWithSeparator) 👎🏼"
            self.labelVideoCommentCount.text = "\(detail.commentCount.formattedWithSeparator) ✍🏼"
            self.stackViewVideoCounts.isHidden = false

            self.view.layoutIfNeeded()
        }, completion: { finished in

        })
    }

    func preparePlayerWithSearchResultItem() {
        guard let video = video else { return }

        youtubePlayerView.delegate = self
        youtubePlayerView.alpha = 0
        activityIndicatorVideo.startAnimating()
        youtubePlayerView.loadVideoID(video.videoID)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedYoutubeFallback",
            let youtubeFallbackVC = segue.destination as? YoutubeFallbackVC
        {
            youtubeFallbackVC.openVideoWithYoutubeID = video?.videoID ?? videoDetail?.id ?? nil
        }
    }

    @IBAction func actionButtonMore(_ sender: UIButton) {
        isVideoDescriptionCollapsed = !isVideoDescriptionCollapsed
        let title = isVideoDescriptionCollapsed ? "More" : "Less"

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.lcLabelVIdeoDescriptionHeight.isActive = self.isVideoDescriptionCollapsed
            self.buttonMore.setTitle(title, for: .normal)
            self.view.layoutIfNeeded()
        }) { _ in }
    }

}


extension JPVideoDetailVC: YouTubePlayerDelegate {

    func playerReady(_ videoPlayer: YouTubePlayerView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.activityIndicatorVideo.stopAnimating()
            self.youtubePlayerView.alpha = 1
        }) { _ in }
    }

    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Playing {
            if firstTimePlayingTheVideo {
                AnalyticsService.sharedInstance.fire(event: .youtubeVideoPlay)
            }

            firstTimePlayingTheVideo = false
        }

        if playerState == .Ended {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                ReviewService.sharedInstance.requestReviewIfNeeded(userDemonstratedEngagement: true)
            }
        }
    }

}
