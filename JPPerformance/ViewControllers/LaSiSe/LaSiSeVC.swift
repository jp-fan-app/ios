//
//  LaSiSeVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 18.05.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds


class LaSiSeVC: JPBaseViewController {

    private var carData: JPCarData?

    @IBOutlet weak var tableView: UITableView!
    var refreshControlTableView = UIRefreshControl()
    @IBOutlet weak var viewLoadingError: UIView!

    private var hasBanner: Bool = false {
        didSet {
            print("set has banner in LaSiSeVC \(hasBanner)")
            lcBannerViewHeight.constant = hasBanner ? 50 : 0

            if ProcessInfo.processInfo.arguments.contains("TAKING_SCREENSHOTS") {
                lcBannerViewHeight.constant = 0
            }
        }
    }

    @IBOutlet var lcBannerViewHeight: NSLayoutConstraint!
    @IBOutlet var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "lasise".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title

        viewLoadingError.alpha = 0

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerLaSiSe()
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(AdMobService.sharedService.request())

        refreshControlTableView.addTarget(self,
                                          action: #selector(LaSiSeVC.didPerformRefreshControl),
                                          for: .valueChanged)
        tableView.addSubview(refreshControlTableView)

        reloadBoard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }

        if carData?.cars.count == 0 {
            reloadBoard()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
            let detailVC = segue.destination as? JPCarDetailVC,
            let carItem = sender as? JPCarItem
        {
            detailVC.carItem = carItem
        }
    }

    @objc func didPerformRefreshControl() {
        refreshControlTableView.beginRefreshing()
        reloadBoard(forceReload: true)
    }

    private func reloadBoard(forceReload: Bool = false) {
        if forceReload {
            SyncService.shared.synchronizeCarInformation {
                self.reloadBoard(forceReload: false)
            }
            return
        }

        CarService.sharedInstance.fetchBoardForLaSiSe { carData in
            self.carData = carData
            self.tableView.reloadData()
            self.refreshControlTableView.endRefreshing()
            self.updateLoadingError()
        }
    }

    private func updateLoadingError() {
        var hasLoadingError = carData?.cars.count ?? 0 == 0
        if SyncService.shared.isSyncing && hasLoadingError {
            hasLoadingError = false
            refreshControlTableView.beginRefreshing()
            var contentOffset = tableView.contentOffset
            contentOffset.y -= refreshControlTableView.frame.size.height
            tableView.setContentOffset(contentOffset, animated: true)
        }

        viewLoadingError.alpha = hasLoadingError ? 1 : 0
    }

}


extension LaSiSeVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carData?.cars.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarStageLaSiSeTableViewCell",
                                                 for: indexPath) as! CarStageLaSiSeTableViewCell
        cell.carItem = carData?.cars[indexPath.row]
        // swiftlint:enable force_cast

        return cell
    }

}

extension LaSiSeVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let carItem = carData?.cars[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: carItem)
    }

}


extension LaSiSeVC: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        hasBanner = true
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hasBanner = false
    }

}
