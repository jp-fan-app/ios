//
//  YoutubeVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds


class JPYoutubeVC: JPBaseViewController {

    var videos: [YoutubeVideoModel] = []

    @IBOutlet weak var tableViewSearchResults: UITableView!
    var refreshControlTableView = UIRefreshControl()
    @IBOutlet weak var viewLoadingError: UIView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    private var hasBanner: Bool = false {
        didSet {
            print("set has banner in YoutubeListVC \(hasBanner)")
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

        title = "youtube".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerVideoList()
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(AdMobService.sharedService.request())

        tableViewSearchResults.rowHeight = UITableView.automaticDimension
        tableViewSearchResults.estimatedRowHeight = 103

        viewLoadingError.alpha = 0

        refreshControlTableView.addTarget(self, action: #selector(JPYoutubeVC.didPerformRefreshControl),
                                          for: .valueChanged)
        tableViewSearchResults.addSubview(refreshControlTableView)

        performSearch()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = tableViewSearchResults.indexPathForSelectedRow {
            tableViewSearchResults.deselectRow(at: selectedIndexPath, animated: true)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdateVideosNotification),
                                               name: SyncService.didUpdateVideosNotification,
                                               object: nil)
    }

    @objc private func didUpdateVideosNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.performSearch()
        }
    }

    func performSearch(forceReload: Bool = false) {
        if forceReload {
            SyncService.shared.synchronizeYoutubeVideos {
                DispatchQueue.main.async {
                    self.performSearch(forceReload: false)
                }
            }
            return
        }

        videos = StorageService.shared.allYoutubeVideos()
        self.tableViewSearchResults.reloadData()
        self.refreshControlTableView.endRefreshing()
        self.updateLoadingError()
    }

    func updateLoadingError() {
        let hasLoadingError = videos.count == 0
        viewLoadingError.alpha = hasLoadingError ? 1 : 0
    }

    @objc func didPerformRefreshControl() {
        refreshControlTableView.beginRefreshing()
        performSearch(forceReload: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
            let detailVC = segue.destination as? JPVideoDetailVC,
            let video = sender as? YoutubeVideoModel
        {
            detailVC.video = video
        }
    }
}


extension JPYoutubeVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "YoutubeVideoCell",
                                                 for: indexPath) as! YoutubeVideoCell
        // swiftlint:enable force_cast
        cell.video = videos[indexPath.row]
        cell.accessibilityIdentifier = "youtubeItemCell_\(indexPath.row)"
        return cell
    }

}


extension JPYoutubeVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: video)
    }

}


extension JPYoutubeVC: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        hasBanner = true
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hasBanner = false
    }

}
