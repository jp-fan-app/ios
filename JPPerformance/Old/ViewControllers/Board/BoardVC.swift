//
//  BoardVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 02.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds


class BoardVC: JPBaseViewController {

    @IBOutlet weak var viewBoardFilter: UIView!
    @IBOutlet weak var segmentedControlBoardFilter: UISegmentedControl!
    @IBOutlet weak var tableViewBoard: UITableView!
    private var carData: JPCarData?
    var refreshControlTableView = UIRefreshControl()
    @IBOutlet weak var viewLoadingError: UIView!

    private var hasBanner: Bool = false {
        didSet {
            print("set has banner in BoardVC \(hasBanner)")
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

        title = "board".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title

        viewLoadingError.alpha = 0

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerBoardList()
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(AdMobService.sharedService.request())

        // Prepare Board Filter
        segmentedControlBoardFilter.setTitleTextAttributes([.font: UIFont(name: "Montserrat", size: 14)!], for: .normal)
        tableViewBoard.tableHeaderView = viewBoardFilter
        viewBoardFilter.widthAnchor.constraint(equalTo: tableViewBoard.widthAnchor, multiplier: 1).isActive = true

        refreshControlTableView.addTarget(self,
                                          action: #selector(BoardVC.didPerformRefreshControl),
                                          for: .valueChanged)
        tableViewBoard.addSubview(refreshControlTableView)

        reloadBoard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedIndexPath = tableViewBoard.indexPathForSelectedRow {
            tableViewBoard.deselectRow(at: selectedIndexPath, animated: true)
        }

        if carData?.cars.count == 0 {
            reloadBoard()
        }
    }

    @IBAction func actionSegmentedControlBoardFilterValueChanged(_ sender: UISegmentedControl) {
        reloadBoard()
    }

    @objc func didPerformRefreshControl() {
        refreshControlTableView.beginRefreshing()
        reloadBoard(forceReload: true)
    }

    private func reloadBoard(forceReload: Bool = false) {
        guard let comparison = selectedComparison() else { return }
        if forceReload {
            SyncService.shared.synchronizeCarInformation {
                self.reloadBoard(forceReload: false)
            }
            return
        }

        func reloadWithCarData(_ carData: JPCarData?) {
            self.carData = carData
            self.tableViewBoard.reloadData()
            self.refreshControlTableView.endRefreshing()
            self.updateLoadingError()
        }

        switch comparison {
        case .range(let string):
            CarService.sharedInstance.fetchBoard(forRange: string) { carData in
                reloadWithCarData(carData)
            }
        case .ps:
            CarService.sharedInstance.fetchBoardForPS { carData in
                reloadWithCarData(carData)
            }
        case .nm:
            CarService.sharedInstance.fetchBoardForNM { carData in
                reloadWithCarData(carData)
            }
        }
    }

    private func updateLoadingError() {
        var hasLoadingError = carData?.cars.count ?? 0 == 0
        if SyncService.shared.isSyncing && hasLoadingError {
            hasLoadingError = false
            refreshControlTableView.beginRefreshing()
            var contentOffset = tableViewBoard.contentOffset
            contentOffset.y -= refreshControlTableView.frame.size.height
            tableViewBoard.setContentOffset(contentOffset, animated: true)
        }

        viewLoadingError.alpha = hasLoadingError ? 1 : 0
        viewBoardFilter.alpha = hasLoadingError ? 0 : 1
    }

    enum Comparison {
        case range(string: String)
        case ps
        case nm
    }

    private func selectedComparison() -> Comparison? {
        switch segmentedControlBoardFilter.selectedSegmentIndex {
        case 0: return .range(string: "0-100")
        case 1: return .range(string: "100-200")
        case 2: return .ps
        case 3: return .nm
        default: return nil
        }
    }

    private func selectedRange() -> String? {
        guard let comparison = selectedComparison() else { return nil }
        switch comparison {
        case .range(let string):
            return string
        default:
            return nil
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

}


extension BoardVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carData?.cars.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let comparison = selectedComparison() else {
            return tableView.dequeueReusableCell(withIdentifier: "CarBoardTableViewCell", for: indexPath)
        }
        // swiftlint:disable force_cast
        switch comparison {
        case .range(let string):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CarBoardTableViewCell",
                                                     for: indexPath) as! CarBoardTableViewCell
            cell.carItem = carData?.cars[indexPath.row]
            cell.range = string
            return cell
        case .ps:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CarBoardTableViewCellPSNM",
                                                     for: indexPath) as! CarBoardTableViewCellPSNM
            cell.carItem = carData?.cars[indexPath.row]
            cell.isPS = true
            cell.isNM = false
            return cell
        case .nm:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CarBoardTableViewCellPSNM",
                                                     for: indexPath) as! CarBoardTableViewCellPSNM
            cell.carItem = carData?.cars[indexPath.row]
            cell.isPS = false
            cell.isNM = true
            return cell
        }
        // swiftlint:enable force_cast
    }

}

extension BoardVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let carItem = carData?.cars[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: carItem)
    }

}


extension BoardVC: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        hasBanner = true
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hasBanner = false
    }

}
