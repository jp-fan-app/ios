//
//  CarModelDetailVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient
import GoogleMobileAds


class CarModelDetailVC: UIViewController {

    var carModel: JPFanAppClient.CarModel? {
        didSet {
            reloadCarModel()
        }
    }

    private var stageTimingsViewModel = StageTimingsViewModel()

    @IBOutlet var imageViewMainImage: UIImageView!
    @IBOutlet var labelCarModelName: UILabel!
    @IBOutlet var imageViewManufacturerLogo: UIImageView!

    @IBOutlet var viewBannerBackground: UIView!
    @IBOutlet var bannerView: GADBannerView!

    @IBOutlet var tableViewStages: UITableView!
    @IBOutlet var lcTableViewStagesHeight: NSLayoutConstraint!

    let http = HTTP()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView?.adSize = kGADAdSizeSmartBannerPortrait
        bannerView?.adUnitID = AdMob.adUnitIDForBottomBannerCarDetail
        bannerView?.rootViewController = self
        bannerView?.delegate = self
        bannerView?.load(AdMob.request())

        tableViewStages.register(UINib(nibName: "CarModelDetailStageHeader", bundle: nil),
                                 forHeaderFooterViewReuseIdentifier: "CarModelDetailStageHeader")

        stageTimingsViewModel.delegate = self

        reloadCarModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    private func reloadCarModel() {
        guard isViewLoaded else { return }
        guard let carModel = carModel else {
            reloadStageTimings()
            return
        }

        labelCarModelName.text = carModel.name
        if let mainImageID = carModel.mainImageID {
            http.getCarImageFile(id: mainImageID).whenSuccess { imageData in
                DispatchQueue.main.async {
                    self.imageViewMainImage.image = UIImage(data: imageData)
                }
            }
        }

        http.getManufacturer(id: carModel.manufacturerID).whenSuccess { manufacturer in
            DispatchQueue.main.async {
                self.imageViewManufacturerLogo.image = ManufacturerLogoMapper.manufacturerLogo(for: manufacturer.name)
            }
        }

        reloadStageTimings()
    }

    private func reloadStageTimings() {
        guard let carModel = carModel else {
            return
        }

        stageTimingsViewModel.reload(carModel: carModel)
    }

    // MARK: - Actions

    @IBAction func actionClose(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}

// MARK: - UITableViewDataSource

extension CarModelDetailVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return stageTimingsViewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stageTimingsViewModel.sections[section].timings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stageTiming = stageTimingsViewModel.sections[indexPath.section].timings[indexPath.row]

        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarModelTimingTableViewCell",
                                                 for: indexPath) as! CarModelTimingTableViewCell
        cell.labelRange.text = stageTiming.range
        cell.labelSecond1.isHidden = stageTiming.second1 == nil
        cell.labelSecond1.text = NumberFormatter.secondsFormatter.string(from: stageTiming.second1)
        cell.labelSecond2.isHidden = stageTiming.second2 == nil
        cell.labelSecond2.text = NumberFormatter.secondsFormatter.string(from: stageTiming.second2)
        cell.labelSecond3.isHidden = stageTiming.second3 == nil
        cell.labelSecond3.text = NumberFormatter.secondsFormatter.string(from: stageTiming.second3)

        // swiftlint:enable force_cast
        return cell
    }

}

// MARK: - UITableViewDelegate

extension CarModelDetailVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // swiftlint:disable force_cast line_length
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CarModelDetailStageHeader") as! CarModelDetailStageHeader
        // swiftlint:enable force_cast line_length
        let stage = stageTimingsViewModel.sections[section].stage
        headerView.viewSeperator.isHidden = section == 0
        headerView.labelStageName.text = stage.name
        headerView.buttonPlayVideo.removeTarget(self, action: nil, for: .allEvents)

        return headerView
    }

}

// MARK: - GADBannerViewDelegate

extension CarModelDetailVC: GADBannerViewDelegate { }

// MARK: - CarModelDetailVCStageTimingsViewModelDelegate

extension CarModelDetailVC: CarModelDetailVCStageTimingsViewModelDelegate {

    func didUpdateStageTimings() {
        DispatchQueue.main.async {
            self.tableViewStages.reloadData()
            self.lcTableViewStagesHeight.constant = self.tableViewStages.contentSize.height
        }
    }

}

// MARK: - Stage Timings View Model

private protocol CarModelDetailVCStageTimingsViewModelDelegate: class {

    func didUpdateStageTimings()

}

private extension CarModelDetailVC {

    class StageTimingsViewModel {

        weak var delegate: CarModelDetailVCStageTimingsViewModelDelegate?

        var sections: [Section] = []

        let http = HTTP()

        func reload(carModel: JPFanAppClient.CarModel) {
            guard let carModelID = carModel.id else { return }
            http.getCarStagesWithMappedTimings(carModelID: carModelID).whenSuccess { stageTimingMappings in
                let newSections = stageTimingMappings.map { stageTimingMapping in
                    return Section(stage: stageTimingMapping.0, timings: stageTimingMapping.1)
                }
                self.sections = newSections
                self.delegate?.didUpdateStageTimings()
            }
        }

    }

}


private extension CarModelDetailVC.StageTimingsViewModel {

    struct Section {

        var stage: JPFanAppClient.CarStage
        var timings: [JPFanAppClient.StageTiming]

    }

}
