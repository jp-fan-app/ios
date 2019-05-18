//
//  SeriesVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 26.10.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds


class SeriesVC: JPBaseViewController {

    var videoSeries: [VideoSerie] = []

    @IBOutlet weak var tableViewVideoSeries: UITableView!
    var refreshControlTableView = UIRefreshControl()
    @IBOutlet weak var viewLoadingError: UIView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    private var hasBanner: Bool = false {
        didSet {
            print("set has banner in YoutubeListVC \(hasBanner)")
//            lcBannerViewHeight.constant = 0
            lcBannerViewHeight.constant = hasBanner ? 50 : 0

            if ProcessInfo.processInfo.arguments.contains("TAKING_SCREENSHOTS") {
                lcBannerViewHeight.constant = 0
            }
        }
    }
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var lcBannerViewHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "series".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerVideoSerieList()
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(AdMobService.sharedService.request())

        tableViewVideoSeries.rowHeight = UITableView.automaticDimension
        tableViewVideoSeries.estimatedRowHeight = 103

        viewLoadingError.alpha = 0

        refreshControlTableView.addTarget(self,
                                          action: #selector(JPYoutubeVC.didPerformRefreshControl),
                                          for: .valueChanged)
        tableViewVideoSeries.addSubview(refreshControlTableView)

        performSearch()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedIndexPath = tableViewVideoSeries.indexPathForSelectedRow {
            tableViewVideoSeries.deselectRow(at: selectedIndexPath, animated: true)
        }

        if videoSeries.count == 0 {
            performSearch()
        }
    }

    func performSearch(forceReload: Bool = false) {
        if forceReload {
            SyncService.shared.synchronizeVideoSeries {
                DispatchQueue.main.async {
                    self.performSearch(forceReload: false)
                }
            }
            return
        }

        videoSeries = StorageService.shared.allVideoSeries()
        self.tableViewVideoSeries.reloadData()
        self.refreshControlTableView.endRefreshing()
        self.updateLoadingError()
    }

    func updateLoadingError() {
        let hasLoadingError = videoSeries.count == 0

        viewLoadingError.alpha = hasLoadingError ? 1 : 0
    }

    @objc func didPerformRefreshControl() {
        refreshControlTableView.beginRefreshing()
        performSearch(forceReload: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
            let detailVC = segue.destination as? VideoSerieDetailVC,
            let videoSerie = sender as? VideoSerie
        {
            detailVC.videoSerie = videoSerie
        }
    }

}

extension SeriesVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoSeries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSerieCell",
                                                 for: indexPath) as! VideoSerieCell
        // swiftlint:enable force_cast
        cell.videoSerie = videoSeries[indexPath.row]
        cell.accessibilityIdentifier = "videoSerieCell_\(indexPath.row)"
        return cell
    }

}


extension SeriesVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoSerie = videoSeries[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: videoSerie)
    }

}


extension SeriesVC: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        hasBanner = true
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hasBanner = false
    }

}
