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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "MainNavigationHeader", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "MainNavigationHeader")

        tableView.register(UINib(nibName: "MainDetailsHeader", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "MainDetailsHeader")

        viewModel.delegate = self
        viewModel.update()
    }

    @objc private func actionMainDetailsHeaderActionButton(_ sender: UIButton) {
        print("show detials")
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
            cell.manufacturers = manufacturerSection.manufacturers
            return cell
        case let carModelSection as ViewModel.CarModelsSection:
            let row = carModelSection.rows[indexPath.row]
            switch row {
            case .carModels(let carModels):
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "CarModelsTableViewCell",
                                                         for: indexPath) as! CarModelsTableViewCell
                // swiftlint:enable force_cast
                cell.carModels = carModels
                return cell
            case .details(let title):
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailsTableViewCell",
                                                         for: indexPath) as! ShowDetailsTableViewCell
                // swiftlint:enable force_cast
                cell.buttonAction.setTitle(title, for: .normal)
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
            cell.youtubeVideos = youtubeVideoSection.youtubeVideos
            return cell
        case let videoSeriesSection as ViewModel.VideoSeriesSection:
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSeriesTableViewCell",
                                                     for: indexPath) as! VideoSeriesTableViewCell
            // swiftlint:enable force_cast
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
            // swiftlint:enable force_cast
            return mainNavigationHeader
        case .detailsHeader(let title):
            // swiftlint:disable force_cast
            let mainDetailsHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainDetailsHeader") as! MainDetailsHeader
            // swiftlint:enable force_cast
            mainDetailsHeader.labelTitle.text = title
            mainDetailsHeader.buttonAction.setTitle("all".localized(), for: .normal)
            mainDetailsHeader.buttonAction.removeTarget(self, action: nil, for: .allEvents)
            mainDetailsHeader.buttonAction.addTarget(self,
                                                     action: #selector(actionMainDetailsHeaderActionButton),
                                                     for: .touchUpInside)
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

}
