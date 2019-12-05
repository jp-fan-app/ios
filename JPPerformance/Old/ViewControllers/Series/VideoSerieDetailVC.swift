//
//  VideoSerieDetailVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 26.10.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds


class VideoSerieDetailVC: JPBaseViewController {

    var videoSerie: VideoSerie? {
        didSet {
            updateVideos()
            guard isViewLoaded else { return }
        }
    }
    var videos: [VideoSerieVideo] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    private var hasBanner: Bool = false {
        didSet {
            print("set has banner in YoutubeListVC \(hasBanner)")
            lcBannerViewHeight.constant = hasBanner ? 50 : 0
        }
    }
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var lcBannerViewHeight: NSLayoutConstraint!

    @IBOutlet var tableViewVideos: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "serie".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerVideoSerieList()
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(AdMobService.sharedService.request())

        tableViewVideos.rowHeight = UITableView.automaticDimension
        tableViewVideos.estimatedRowHeight = 103
        updateVideos()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedIndexPath = tableViewVideos.indexPathForSelectedRow {
            tableViewVideos.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    private func updateVideos() {
        guard isViewLoaded else { return }
        videos = videoSerie?.videosNewestAtFirst() ?? []
        tableViewVideos.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideoDetail",
            let detailVC = segue.destination as? JPVideoDetailVC,
            let video = sender as? YoutubeVideoModel
        {
            detailVC.video = video
        }
    }

}

extension VideoSerieDetailVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSerieVideoCell",
                                                 for: indexPath) as! VideoSerieVideoCell
        // swiftlint:enable force_cast
        cell.videoSerieVideo = videos[indexPath.row]
        cell.accessibilityIdentifier = "videoSerieVideoCell_\(indexPath.row)"
        return cell
    }

}


extension VideoSerieDetailVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let video = videos[indexPath.row].youtubeVideo else { return }
        performSegue(withIdentifier: "showVideoDetail", sender: video)
    }

}


extension VideoSerieDetailVC: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        hasBanner = true
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hasBanner = false
    }

}
