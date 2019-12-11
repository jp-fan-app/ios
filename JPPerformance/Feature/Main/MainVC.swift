//
//  MainVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class MainVC: UIViewController {

    @IBOutlet var tableView: UITableView!

    private let viewModel = ViewModel()

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "MainNavigationHeader", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "MainNavigationHeader")

        tableView.register(UINib(nibName: "MainDetailsHeader", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "MainDetailsHeader")

        viewModel.delegate = self
        viewModel.update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCarModelDetail",
            let navController = segue.destination as? UINavigationController,
            let carModelDetailVC = navController.topViewController as? CarModelDetailVC,
            let carModel = sender as? JPFanAppClient.CarModel
        {
            carModelDetailVC.carModel = carModel
        }

        if segue.identifier == "showYoutubeVideoDetail",
            let youtubePlayerVC = segue.destination as? YoutubePlayerVC,
            let youtubeVideo = sender as? JPFanAppClient.YoutubeVideo
        {
            youtubePlayerVC.modalPresentationStyle = .fullScreen
            youtubePlayerVC.youtubeVideo = youtubeVideo
        }

        if segue.identifier == "showVideoSerieDetail",
            let videoSerieDetailVC = segue.destination as? VideoSerieDetailVC,
            let videoSerie = sender as? JPFanAppClient.VideoSerie
        {
            videoSerieDetailVC.videoSerie = videoSerie
        }
    }


    @objc private func actionMainNavigationHeaderPerformanceBoard(_ sender: UIButton) {
        performSegue(withIdentifier: "showPerformanceBoard", sender: self)
    }

    @objc private func actionMainNavigationHeaderSearch(_ sender: UIButton) {
        performSegue(withIdentifier: "showCarModelsSearch", sender: self)
    }


    @objc private func actionMainDetailsHeaderActionButtonManufacturerSection(_ sender: UIButton) {
        performSegue(withIdentifier: "showManufacturersList", sender: self)
    }

    @objc private func actionMainDetailsHeaderActionButtonYoutubeVideoSection(_ sender: UIButton) {
        performSegue(withIdentifier: "showYoutubeVideosList", sender: self)
    }

    @objc private func actionMainDetailsHeaderActionButtonVideoSerieSection(_ sender: UIButton) {
        performSegue(withIdentifier: "showVideoSeriesList", sender: self)
    }

    @objc private func actionShowDetailsCarModelsRow(_ sender: UIButton) {
        performSegue(withIdentifier: "showCarModelsSearch", sender: self)
    }

}

// MARK: - UITableViewDataSource

extension MainVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let viewModelSection = viewModel.sections[section]
        return viewModelSection.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModelSection = viewModel.sections[indexPath.section]

        switch viewModelSection {
        case let manufacturerSection as ViewModel.ManufacturerSection:
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManufacturersTableViewCell",
                                                     for: indexPath) as! ManufacturersTableViewCell
            // swiftlint:enable force_cast
            cell.delegate = self
            cell.manufacturers = manufacturerSection.manufacturers
            cell.selectedManufacturer = viewModel.selectedManufacturer
            return cell
        case let carModelSection as ViewModel.CarModelsSection:
            let row = carModelSection.rows[indexPath.row]
            switch row {
            case .carModels(let carModels):
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "CarModelsTableViewCell",
                                                         for: indexPath) as! CarModelsTableViewCell
                // swiftlint:enable force_cast
                cell.delegate = self
                cell.carModels = carModels
                return cell
            case .details(let title):
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailsTableViewCell",
                                                         for: indexPath) as! ShowDetailsTableViewCell
                // swiftlint:enable force_cast
                cell.buttonAction.setTitle(title, for: .normal)
                cell.buttonAction.removeTarget(self, action: nil, for: .allEvents)
                cell.buttonAction.addTarget(self, action: #selector(actionShowDetailsCarModelsRow), for: .touchUpInside)
                return cell
            case .admob(let id):
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdMobTableViewCell",
                                                         for: indexPath) as! AdMobTableViewCell
                // swiftlint:enable force_cast
                cell.loadAd(adId: id, rootViewController: self)
                return cell
            }
        case let youtubeVideoSection as ViewModel.YoutubeVideosSection:
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "YoutubeVideosTableViewCell",
                                                     for: indexPath) as! YoutubeVideosTableViewCell
            // swiftlint:enable force_cast
            cell.delegate = self
            cell.youtubeVideos = youtubeVideoSection.youtubeVideos
            return cell
        case let videoSeriesSection as ViewModel.VideoSeriesSection:
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSeriesTableViewCell",
                                                     for: indexPath) as! VideoSeriesTableViewCell
            // swiftlint:enable force_cast
            cell.delegate = self
            cell.videoSeries = videoSeriesSection.videoSeries
            return cell

        // VideoCell

        default:
            return tableView.dequeueReusableCell(withIdentifier: "AdMobCell")!
        }
    }

}

// MARK: - UITableViewDelegate

extension MainVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let viewModelSection = viewModel.sections[section]
        switch viewModelSection.headerType {
        case .none:
            return 0
        case .navigationHeader:
            return 100
        case .detailsHeader:
            return 50
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewModelSection = viewModel.sections[section]
        switch viewModelSection.headerType {
        case .none:
            return nil
        case .navigationHeader:
            // swiftlint:disable force_cast
            let mainNavigationHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainNavigationHeader") as! MainNavigationHeader
            mainNavigationHeader.buttonPerformanceBoard.removeTarget(self, action: nil, for: .allEvents)
            mainNavigationHeader.buttonPerformanceBoard.addTarget(self,
                                                                  action: #selector(actionMainNavigationHeaderPerformanceBoard),
                                                                  for: .touchUpInside)
            mainNavigationHeader.buttonSearch.removeTarget(self, action: nil, for: .allEvents)
            mainNavigationHeader.buttonSearch.addTarget(self,
                                                        action: #selector(actionMainNavigationHeaderSearch),
                                                        for: .touchUpInside)
            // swiftlint:enable force_cast
            return mainNavigationHeader
        case .detailsHeader(let title):
            // swiftlint:disable force_cast
            let mainDetailsHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainDetailsHeader") as! MainDetailsHeader
            // swiftlint:enable force_cast
            mainDetailsHeader.labelTitle.text = title
            mainDetailsHeader.buttonAction.setTitle("all".localized(), for: .normal)
            mainDetailsHeader.buttonAction.removeTarget(self, action: nil, for: .allEvents)
            switch viewModelSection {
            case is ViewModel.ManufacturerSection:
                mainDetailsHeader.buttonAction.addTarget(self,
                                                         action: #selector(actionMainDetailsHeaderActionButtonManufacturerSection),
                                                         for: .touchUpInside)
            case is ViewModel.YoutubeVideosSection:
                mainDetailsHeader.buttonAction.addTarget(self,
                                                         action: #selector(actionMainDetailsHeaderActionButtonYoutubeVideoSection),
                                                         for: .touchUpInside)
            case is ViewModel.VideoSeriesSection:
                mainDetailsHeader.buttonAction.addTarget(self,
                                                         action: #selector(actionMainDetailsHeaderActionButtonVideoSerieSection),
                                                         for: .touchUpInside)
            default:
                break
            }
            return mainDetailsHeader
        }
    }

}

// MARK: - MainVCViewModelDelegate

extension MainVC: MainVCViewModelDelegate {

    func didUpdateSections() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func didUpdateSection(section: Int) {
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }

}

// MARK: - CarModelsTableViewCellDelegate

extension MainVC: CarModelsTableViewCellDelegate {

    func carModelsTableViewCell(_ carModelsTableViewCell: CarModelsTableViewCell,
                                didSelect carModel: JPFanAppClient.CarModel) {
        performSegue(withIdentifier: "showCarModelDetail", sender: carModel)
    }

}

// MARK: - ManufacturersTableViewCellDelegate

extension MainVC: ManufacturersTableViewCellDelegate {

    func manufacturersTableViewCell(_ manufacturersTableViewCell: ManufacturersTableViewCell,
                                    didSelect manufacturer: JPFanAppClient.ManufacturerModel) {
        viewModel.selectManufacturer(manufacturer)
    }

}

// MARK: - YoutubeVideosTableViewCellDelegate

extension MainVC: YoutubeVideosTableViewCellDelegate {

    func youtubeVideosTableViewCell(_ youtubeVideosTableViewCell: YoutubeVideosTableViewCell,
                                    didSelect youtubeVideo: JPFanAppClient.YoutubeVideo) {
        performSegue(withIdentifier: "showYoutubeVideoDetail", sender: youtubeVideo)
    }

}

// MARK: - VideoSeriesTableViewCellDelegate

extension MainVC: VideoSeriesTableViewCellDelegate {

    func videoSeriesTableViewCell(_ videoSeriesTableViewCell: VideoSeriesTableViewCell,
                                  didSelect videoSerie: JPFanAppClient.VideoSerie) {
        performSegue(withIdentifier: "showVideoSerieDetail", sender: videoSerie)
    }

}
