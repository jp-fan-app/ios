//
//  MainVC+ViewModel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit.UIApplication
import Foundation
import JPFanAppClient


protocol MainVCViewModelDelegate: class {

    func didUpdateSections()
    func didUpdateSection(section: Int)

}


internal extension MainVC {

    class ViewModel {

        private let http = UIApplication.http
        private var manufacturers: [JPFanAppClient.ManufacturerModel] = []
        private var carModels: [JPFanAppClient.CarModel] = []
        private var youtubeVideos: [JPFanAppClient.YoutubeVideo] = []
        private var videoSeries: [JPFanAppClient.VideoSerie] = []

        private(set) var selectedManufacturer: JPFanAppClient.ManufacturerModel?

        internal private(set) var sections: [Section] = []

        weak var delegate: MainVCViewModelDelegate?

        func update() {
            updateManufacturers()
            updateCarModels(singleSectionUpdate: false)
            updateYoutubeVideos()
            updateVideoSeries()
        }

        func selectManufacturer(_ manufacturer: JPFanAppClient.ManufacturerModel) {
            selectedManufacturer = manufacturer
            updateCarModels(singleSectionUpdate: true)
        }

        func updateManufacturers() {
            http.getManufacturers().whenSuccess { index in
                self.manufacturers = index
                self.updateSections()
                self.updateSelectedManufacturer()
            }
        }

        func updateCarModels(singleSectionUpdate: Bool) {
            if let selectedManufacturerID = selectedManufacturer?.id {
                http.getManufacturerCarModels(id: selectedManufacturerID).whenSuccess { index in
                    self.carModels = index
                    self.updateSections(onlyCarModels: singleSectionUpdate)
                }
            } else {
                http.getCarModels().whenSuccess { index in
                    self.carModels = index
                    self.updateSections(onlyCarModels: singleSectionUpdate)
                }
            }
        }

        func updateYoutubeVideos() {
            http.getYoutubeVideos().whenSuccess { index in
                self.youtubeVideos = index.sorted(by: { $0.publishedAt > $1.publishedAt })
                self.updateSections()
                self.updateSelectedManufacturer()
            }
        }

        func updateVideoSeries() {
            http.getVideoSeries().whenSuccess { index in
                self.videoSeries = index.sorted(by: { ($0.updatedAt ?? Date()) > ($1.updatedAt ?? Date()) })
                self.updateSections()
            }
        }

        private func updateSelectedManufacturer() {
            let newFirstManufacturer = manufacturers.first
            if selectedManufacturer?.id != newFirstManufacturer?.id {
                selectedManufacturer = manufacturers.first
                updateCarModels(singleSectionUpdate: true)
            }
        }

        private func updateSections(onlyCarModels: Bool = false) {
            if onlyCarModels, let indexOfCarModelSection = sections.firstIndex(where: { $0 is CarModelsSection }) {
                if let newModelsSection = carModelsSection() {
                    sections[indexOfCarModelSection] = newModelsSection
                    delegate?.didUpdateSection(section: Int(indexOfCarModelSection))
                    return
                }
            }
            var newSections = [
                Section(headerType: .navigationHeader)
            ]
            let optionalSections = [
                manufacturersSection(),
                carModelsSection(),
                youtubeVideosSection(),
                videoSeriesSection()
            ]
            newSections.append(contentsOf: optionalSections.compactMap({ $0 }))

            sections = newSections
            delegate?.didUpdateSections()
        }

        private func manufacturersSection() -> ManufacturerSection? {
            guard manufacturers.count > 0 else { return nil }

            var manufacturers: [JPFanAppClient.ManufacturerModel] = []

            // try to prefer manufacturers from recent videos
            if youtubeVideos.count > 0 {
                let sortedVideos = youtubeVideos.sorted(by: { $0.publishedAt > $1.publishedAt })
                let recentVideos = Array(sortedVideos.prefix(14))
                var manufacturersWithVideos: [(JPFanAppClient.ManufacturerModel, Int)] = []
                var manufacturersWithoutVideos: [JPFanAppClient.ManufacturerModel] = []

                for manufacturer in self.manufacturers {
                    let videoWithIndex = recentVideos.enumerated().first { tuple in
                        let (_, youtubeVideo) = tuple
                        let nameInTitle = youtubeVideo.title.lowercased().contains(manufacturer.name.lowercased())
                        let nameInDescription = youtubeVideo.description.lowercased().contains(manufacturer.name.lowercased())
                        return nameInTitle || nameInDescription
                    }
                    if let videoWithIndex = videoWithIndex {
                        let (index, _) = videoWithIndex
                        manufacturersWithVideos.append((manufacturer, index))
                    } else {
                        manufacturersWithoutVideos.append(manufacturer)
                    }
                }
                let manufacturersWithVideosSortedByVideos = manufacturersWithVideos
                    .sorted(by: { $0.1 < $1.1 })
                    .map { $0.0 }
                manufacturers.append(contentsOf: manufacturersWithVideosSortedByVideos)
                manufacturers.append(contentsOf: manufacturersWithoutVideos)

            } else {
                manufacturers = self.manufacturers
            }

            self.manufacturers = manufacturers.filter({ ManufacturerLogoMapper.manufacturerLogo(for: $0.name) != nil })

            let title = "choose-a-manufacturer".localized()
            return ManufacturerSection(headerType: .detailsHeader(title: title),
                                       manufacturers: Array(self.manufacturers.prefix(5)))
        }

        private func carModelsSection() -> CarModelsSection? {
            guard carModels.count > 0 else { return nil }
            return CarModelsSection(headerType: .none,
                                    carModels: Array(carModels.prefix(2)),
                                    detailsRowTitle: "show-all-car-models".localized(),
                                    hasAdRow: true)
        }

        private func youtubeVideosSection() -> YoutubeVideosSection? {
            guard youtubeVideos.count > 0 else { return nil }
            let title = "recent-videos".localized()
            return YoutubeVideosSection(headerType: .detailsHeader(title: title),
                                        youtubeVideos: Array(youtubeVideos.prefix(5)))
        }

        private func videoSeriesSection() -> VideoSeriesSection? {
            guard videoSeries.count > 0 else { return nil }
            let title = "video-series".localized()
            return VideoSeriesSection(headerType: .detailsHeader(title: title),
                                      videoSeries: Array(videoSeries.prefix(5)))
        }

    }

}

internal extension MainVC.ViewModel {

    class Section {

        enum HeaderType {

            case none
            case navigationHeader
            case detailsHeader(title: String)

        }

        public let headerType: HeaderType

        init(headerType: HeaderType) {
            self.headerType = headerType
        }

        public func numberOfRows() -> Int { return 0 }

    }

}

// MARK: - Manufacturer Section

internal extension MainVC.ViewModel {

    class ManufacturerSection: Section {

        public let manufacturers: [JPFanAppClient.ManufacturerModel]

        init(headerType: HeaderType, manufacturers: [JPFanAppClient.ManufacturerModel]) {
            self.manufacturers = manufacturers

            super.init(headerType: headerType)
        }

        override func numberOfRows() -> Int {
            return 1
        }

    }

}

// MARK: - Car Model Section

internal extension MainVC.ViewModel {

    class CarModelsSection: Section {

        enum Row {

            case carModels(carModels: [JPFanAppClient.CarModel])
            case details(title: String)
            case admob(id: String)

        }

        public let rows: [Row]

        init(headerType: HeaderType, carModels: [JPFanAppClient.CarModel], detailsRowTitle: String?, hasAdRow: Bool) {
            var rows = [
                Row.carModels(carModels: carModels)
            ]

            if let title = detailsRowTitle {
                rows.append(.details(title: title))
            }

            if hasAdRow {
                rows.append(.admob(id: AdMob.adUnitIDForBottomBannerCarList))
            }

            self.rows = rows

            super.init(headerType: headerType)
        }

        override func numberOfRows() -> Int {
            return rows.count
        }

    }

}

// MARK: - YoutubeVideo Section

internal extension MainVC.ViewModel {

    class YoutubeVideosSection: Section {

        public let youtubeVideos: [JPFanAppClient.YoutubeVideo]

        init(headerType: HeaderType, youtubeVideos: [JPFanAppClient.YoutubeVideo]) {
            self.youtubeVideos = youtubeVideos

            super.init(headerType: headerType)
        }

        override func numberOfRows() -> Int {
            return 1
        }

    }

}

// MARK: - VideoSeries Section

internal extension MainVC.ViewModel {

    class VideoSeriesSection: Section {

        public let videoSeries: [JPFanAppClient.VideoSerie]

        init(headerType: HeaderType, videoSeries: [JPFanAppClient.VideoSerie]) {
            self.videoSeries = videoSeries

            super.init(headerType: headerType)
        }

        override func numberOfRows() -> Int {
            return 1
        }

    }

}
