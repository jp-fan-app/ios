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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    var carModel: JPFanAppClient.CarModel? {
        didSet {
            reloadCarModel()
        }
    }

    private var stageTimingsViewModel = StageTimingsViewModel()

    @IBOutlet var lcViewImageBackgroundNoImageRatio: NSLayoutConstraint!
    @IBOutlet var imageViewMainImage: UIImageView!
    @IBOutlet var labelCarModelName: UILabel!
    @IBOutlet var imageViewManufacturerLogo: UIImageView!

    @IBOutlet var viewBannerBackground: UIView!
    @IBOutlet var bannerView: GADBannerView!

    @IBOutlet var tableViewStages: UITableView!
    @IBOutlet var lcTableViewStagesHeight: NSLayoutConstraint!
    @IBOutlet var barButtonItemClose: UIBarButtonItem!

    private let http = UIApplication.http

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageViewMainImage.image = nil
        barButtonItemClose.title = "close".localized()

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showYoutubeVideoDetail",
            let youtubePlayerVC = segue.destination as? YoutubePlayerVC,
            let youtubeVideo = sender as? JPFanAppClient.YoutubeVideo
        {
            youtubePlayerVC.modalPresentationStyle = .fullScreen
            youtubePlayerVC.youtubeVideo = youtubeVideo
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
            http.getCarImageFile(id: mainImageID).whenComplete { result in
                switch result {
                case .success(let imageData):
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.imageViewMainImage.image = image
                        self.lcViewImageBackgroundNoImageRatio.isActive = false
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self.imageViewMainImage.image = nil
                        self.lcViewImageBackgroundNoImageRatio.isActive = true
                    }
                }
            }
        } else {
            imageViewMainImage.image = nil
            lcViewImageBackgroundNoImageRatio.isActive = true
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
        let timing = stageTimingsViewModel.sections[indexPath.section].timings[indexPath.row]

        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarModelTimingTableViewCell",
                                                 for: indexPath) as! CarModelTimingTableViewCell
        switch timing {
        case .stageTiming(let stageTiming):
            cell.labelRange.text = stageTiming.range
            cell.labelSecond1.isHidden = stageTiming.second1 == nil
            cell.labelSecond1.text = NumberFormatter.secondsFormatter.string(from: stageTiming.second1)
            cell.labelSecond2.isHidden = stageTiming.second2 == nil
            cell.labelSecond2.text = NumberFormatter.secondsFormatter.string(from: stageTiming.second2)
            cell.labelSecond3.isHidden = stageTiming.second3 == nil
            cell.labelSecond3.text = NumberFormatter.secondsFormatter.string(from: stageTiming.second3)
        case .laSiSe(let value):
            cell.labelRange.text = "LaSiSe"
            cell.labelSecond1.isHidden = false
            cell.labelSecond1.text = value.formattedLaSiSeDisplayString()
            cell.labelSecond2.isHidden = true
            cell.labelSecond2.text = nil
            cell.labelSecond3.isHidden = true
            cell.labelSecond3.text = nil
        }

        // swiftlint:enable force_cast
        return cell
    }

}

// MARK: - UITableViewDelegate

extension CarModelDetailVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let stage = stageTimingsViewModel.sections[section].stage
        return stage.hasStageAttributes() ? 100 : 70
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // swiftlint:disable force_cast line_length
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CarModelDetailStageHeader") as! CarModelDetailStageHeader
        // swiftlint:enable force_cast line_length
        let stage = stageTimingsViewModel.sections[section].stage
        headerView.viewSeperator.isHidden = section == 0
        headerView.labelStageName.text = stage.name
        headerView.viewStageAttributes.isHidden = !stage.hasStageAttributes()
        headerView.labelStageAttributePS.text = NumberFormatter.psFormatter.string(from: stage.ps)
        headerView.labelStageAttributeNM.text = NumberFormatter.nmFormatter.string(from: stage.nm)
        headerView.delegate = self
        headerView.preparePlayButton(for: stage)

        return headerView
    }

}

// MARK: - GADBannerViewDelegate

extension CarModelDetailVC: GADBannerViewDelegate { }

extension CarModelDetailVC: CarModelDetailStageHeaderDelegate {

    func carModelDetailStageHeader(_ carModelDetailStageHeader: CarModelDetailStageHeader,
                                   show videos: [JPFanAppClient.YoutubeVideo]) {
        if videos.count == 1, let video = videos.first {
            self.performSegue(withIdentifier: "showYoutubeVideoDetail", sender: video)
        } else {
            let alertController = UIAlertController(title: "car_detail_video_selection_alert_title".localized(),
                                                    message: "car_detail_video_selection_alert_message".localized(),
                                                    preferredStyle: .actionSheet)
            for video in videos {
                alertController.addAction(UIAlertAction(title: video.shortTitle(), style: .default, handler: { _ in
                    self.performSegue(withIdentifier: "showYoutubeVideoDetail", sender: video)
                }))
            }
            alertController.addAction(UIAlertAction(title: "car_detail_video_selection_alert_button_cancel".localized(),
                                                    style: .cancel,
                                                    handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

}

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

        private let http = UIApplication.http

        func reload(carModel: JPFanAppClient.CarModel) {
            guard let carModelID = carModel.id else { return }
            http.getCarStagesWithMappedTimings(carModelID: carModelID).whenSuccess { stageTimingMappings in
                let newSections = stageTimingMappings.map { stageTimingMapping -> Section in
                    let carStage = stageTimingMapping.0
                    var timings: [Section.Timing] = stageTimingMapping.1.map { timing in
                        return .stageTiming(value: timing)
                    }
                    if let lasiseInSeconds = carStage.lasiseInSeconds {
                        timings.append(.laSiSe(value: lasiseInSeconds))
                    }

                    return Section(stage: carStage, timings: timings)
                }
                self.sections = newSections
                self.delegate?.didUpdateStageTimings()
            }
        }

    }

}


private extension CarModelDetailVC.StageTimingsViewModel {

    struct Section {

        enum Timing {

            case stageTiming(value: JPFanAppClient.StageTiming)
            case laSiSe(value: Double)

        }

        var stage: JPFanAppClient.CarStage
        var timings: [Timing]

    }

}
