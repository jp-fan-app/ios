//
//  MainVC+ViewModel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import JPFanAppClient


protocol MainVCViewModelDelegate: class {

    func didUpdateSections()

}

internal extension MainVC {

    class ViewModel {

        private let http = HTTP()
        private var manufacturers: [JPFanAppClient.ManufacturerModel] = []
        private var carModels: [JPFanAppClient.CarModel] = []
        private var youtubeVideos: [JPFanAppClient.YoutubeVideo] = []
        private var videoSeries: [JPFanAppClient.VideoSerie] = []

        internal private(set) var sections: [Section] = []

        weak var delegate: MainVCViewModelDelegate?

        func update() {
            updateManufacturers()
            updateCarModels()
            updateYoutubeVideos()
            updateVideoSeries()
        }

        func updateManufacturers() {
            http.getManufacturers().whenSuccess { index in
                self.manufacturers = index
                self.updateSections()
            }
        }

        func updateCarModels() {
            http.getCarModels().whenSuccess { index in
                self.carModels = index
                self.updateSections()
            }
        }

        func updateYoutubeVideos() {
            http.getYoutubeVideos().whenSuccess { index in
                self.youtubeVideos = index
                self.updateSections()
            }
        }

        func updateVideoSeries() {
            http.getVideoSeries().whenSuccess { index in
                self.videoSeries = index
                self.updateSections()
            }
        }

        private func updateSections() {
            var newSections = [
                Section(headerType: .navigationHeader)
            ]

            if manufacturers.count > 0 {
                let title = "choose-a-manufacturer".localized()
                newSections.append(ManufacturerSection(headerType: .detailsHeader(title: title),
                                                       manufacturers: Array(manufacturers.prefix(5))))
            }

            if carModels.count > 0 {
                newSections.append(CarModelsSection(headerType: .none,
                                                    carModels: Array(carModels.prefix(2)),
                                                    detailsRowTitle: "show-all-car-models".localized(),
                                                    hasAdRow: true))
            }

            if youtubeVideos.count > 0 {
                let title = "recent-videos".localized()
                newSections.append(YoutubeVideosSection(headerType: .detailsHeader(title: title),
                                                        youtubeVideos: Array(youtubeVideos.prefix(5))))
            }

            if videoSeries.count > 0 {
                let title = "video-series".localized()
                newSections.append(VideoSeriesSection(headerType: .detailsHeader(title: title),
                                                      videoSeries: Array(videoSeries.prefix(5))))
            }

            sections = newSections
            delegate?.didUpdateSections()
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
