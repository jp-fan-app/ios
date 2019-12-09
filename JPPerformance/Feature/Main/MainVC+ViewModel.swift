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

        private(set) var selectedManufacturer: JPFanAppClient.ManufacturerModel?

        internal private(set) var sections: [Section] = []

        weak var delegate: MainVCViewModelDelegate?

        func update() {
            updateManufacturers()
            updateCarModels()
            updateYoutubeVideos()
            updateVideoSeries()
        }

        func selectManufacturer(_ manufacturer: JPFanAppClient.ManufacturerModel) {
            selectedManufacturer = manufacturer
            updateCarModels()
        }

        func updateManufacturers() {
            http.getManufacturers().whenSuccess { index in
                self.manufacturers = index
                self.updateSections()
                self.updateSelectedManufacturer()
            }
        }

        func updateCarModels() {
            if let selectedManufacturerID = selectedManufacturer?.id {
                http.getManufacturerCarModels(id: selectedManufacturerID).whenSuccess { index in
                    self.carModels = index
                    self.updateSections()
                }
            } else {
                http.getCarModels().whenSuccess { index in
                    self.carModels = index
                    self.updateSections()
                }
            }
        }

        func updateYoutubeVideos() {
            http.getYoutubeVideos().whenSuccess { index in
                self.youtubeVideos = index
                self.updateSections()
                self.updateSelectedManufacturer()
            }
        }

        func updateVideoSeries() {
            http.getVideoSeries().whenSuccess { index in
                self.videoSeries = index
                self.updateSections()
            }
        }

        private func updateSelectedManufacturer() {
            let newFirstManufacturer = manufacturers.first
            if selectedManufacturer?.id != newFirstManufacturer?.id {
                selectedManufacturer = manufacturers.first
                updateCarModels()
            }
        }

        private func updateSections() {
            var newSections = [
                Section(headerType: .navigationHeader)
            ]

            if manufacturers.count > 0 {
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
                newSections.append(ManufacturerSection(headerType: .detailsHeader(title: title),
                                                       manufacturers: Array(self.manufacturers.prefix(5))))
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
