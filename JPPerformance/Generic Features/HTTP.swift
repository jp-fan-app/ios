//
//  HTTP.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 04.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Foundation
import NIO
import UIKit.UIImage
@_exported import JPFanAppClient


public class HTTP {

    enum Error: Swift.Error {

        case unknown
        case notAnURL

    }

    private let httpClient: JPFanAppClient
    private let cache: Cache?

    public init() {
        self.httpClient = JPFanAppClient.production(accessToken: Keys.jpAPIKey())
        self.cache = Cache()
    }

    // MARK: - Manufacturers

    @discardableResult
    public func getManufacturers() -> EventLoopFuture<[JPFanAppClient.ManufacturerModel]> {
        if let cached = cache?.cachedManufacturersIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.manufacturersIndex().map { index in
            self.cache?.store(manufacturersIndex: index)
            return index
        }
    }

    @discardableResult
    public func getManufacturer(id: Int) -> EventLoopFuture<JPFanAppClient.ManufacturerModel> {
        if let cached = cache?.cached(manufacturerID: id) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.manufacturersShow(id: id).map { single in
            self.cache?.store(manufacturer: single)
            return single
        }
    }

    @discardableResult
    func getManufacturerCarModels(id: Int) -> EventLoopFuture<[JPFanAppClient.CarModel]> {
        if let cached = cache?.cachedCarModelsFor(manufacturerId: id) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.manufacturersModels(id: id).map { index in
            self.cache?.store(carModels: index, forManufacturer: id)
            return index
        }
    }

    // MARK: - Car Models

    @discardableResult
    public func getCarModels() -> EventLoopFuture<[JPFanAppClient.CarModel]> {
        if let cached = cache?.cachedCarModelsIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.modelsIndex().map { index in
            self.cache?.store(carModelsIndex: index)
            return index
        }
    }

    // MARK: - Car Images

    @discardableResult
    public func getCarImages() -> EventLoopFuture<[JPFanAppClient.CarImage]> {
        if let cached = cache?.cachedCarImagesIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.imagesIndex().map { index in
            self.cache?.store(carImagesIndex: index)
            return index
        }
    }

    @discardableResult
    public func getCarImages(carModelId: Int) -> EventLoopFuture<[JPFanAppClient.CarImage]> {
        if let cached = cache?.cachedCarImagesForCarModel(carModelId: carModelId) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.modelsImages(id: carModelId).map { index in
            self.cache?.store(carImages: index, carModelId: carModelId)
            return index
        }
    }

    public func getCarImageFile(id: Int) -> EventLoopFuture<Data> {
        if let cached = cache?.cachedCarImageData(carImageID: id) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.imagesFile(id: id).map { data in
            self.cache?.store(carImageID: id, carImageData: data)
            return data
        }
    }

    // MARK: - Car Stages

    @discardableResult
    public func getCarStages() -> EventLoopFuture<[JPFanAppClient.CarStage]> {
        if let cached = cache?.cachedCarStagesIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.stagesIndex().map { index in
            self.cache?.store(carStagesIndex: index)
            return index
        }
    }

    @discardableResult
    public func getCarStages(carModelID: Int) -> EventLoopFuture<[JPFanAppClient.CarStage]> {
        // TODO: Cache
        return httpClient.modelsStages(id: carModelID).map { index in
            return index
        }
    }

    public typealias CarStageWithTimingsMapping = (JPFanAppClient.CarStage, [JPFanAppClient.StageTiming])
    public func getCarStagesWithMappedTimings(carModelID: Int) -> EventLoopFuture<[CarStageWithTimingsMapping]> {
        return getCarStages(carModelID: carModelID).and(getStageTimings()).map { (tuple) in
            let (carStages, allTimings) = tuple
            let stageTimings: [(JPFanAppClient.CarStage, [JPFanAppClient.StageTiming])] = carStages.compactMap { carStage in
                // TODO: return car stages without timings?
                let timings = allTimings.filter({ $0.stageID == carStage.id })
                if timings.count > 0 {
                    return (carStage, timings)
                } else {
                    return nil
                }
            }
            return stageTimings
        }
    }

    // MARK: - Stage Timings

    @discardableResult
    public func getStageTimings() -> EventLoopFuture<[JPFanAppClient.StageTiming]> {
        if let cached = cache?.cachedStageTimingsIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.timingsIndex().map { index in
            self.cache?.store(stageTimingsIndex: index)
            return index
        }
    }

    // MARK: - Youtube Videos

    @discardableResult
    public func getYoutubeVideos() -> EventLoopFuture<[JPFanAppClient.YoutubeVideo]> {
        if let cached = cache?.cachedYoutubeVideosIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.videosIndex().map { index in
            self.cache?.store(youtubeVideosIndex: index)
            return index
        }
    }

    @discardableResult
    func getCarStageVideos(carStageId: Int) -> EventLoopFuture<[JPFanAppClient.YoutubeVideo]> {
        if let cached = cache?.cachedCarStageVideos(carStageId: carStageId) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.stagesVideos(id: carStageId).map { index in
            self.cache?.store(youtubeVideos: index, forCarStage: carStageId)
            return index
        }
    }

    @discardableResult
    func getVideoSerieVideos(videoSerieId: Int) -> EventLoopFuture<[JPFanAppClient.YoutubeVideo]> {
        if let cached = cache?.cachedVideoSerieVideos(videoSerieId: videoSerieId) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.videoSeriesVideos(id: videoSerieId).map { index in
            let videoIndex = index.map { $0.video }
            self.cache?.store(youtubeVideos: videoIndex, forVideoSerie: videoSerieId)
            return videoIndex
        }
    }

    @discardableResult
    public func getStagesVideos() -> EventLoopFuture<[JPFanAppClient.CarStageYoutubeVideoRelation]> {
        if let cached = cache?.cachedCarStageVideoRelationsIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.stagesVideosRelations().map { index in
            self.cache?.store(carStageVideoRelationsIndex: index)
            return index
        }
    }

    // MARK: - Video Series

    @discardableResult
    public func getVideoSeries() -> EventLoopFuture<[JPFanAppClient.VideoSerie]> {
        if let cached = cache?.cachedVideoSeriesIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.videoSeriesIndex().map { index in
            self.cache?.store(videoSeriesIndex: index)
            return index
        }
    }

    @discardableResult
    public func getVideoSerieYoutubeVideos() -> EventLoopFuture<[JPFanAppClient.VideoSerieYoutubeVideoRelation]> {
        if let cached = cache?.cachedVideoSerieYoutubeVideosIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.videoSeriesVideosRelations().map { index in
            self.cache?.store(videoSeriesYoutubeVideosIndex: index)
            return index
        }
    }

    // MARK: - Public Images

    @discardableResult
    public func getPublicImage(url urlString: String) -> EventLoopFuture<UIImage> {
        guard let url = URL(string: urlString) else {
            return httpClient.nextEventLoop().makeFailedFuture(Error.notAnURL)
        }
        if let cached = cache?.cached(publicImageURL: urlString) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }

        let dataPromise = httpClient.nextEventLoop().makePromise(of: UIImage.self)
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                dataPromise.fail(Error.unknown)
                return
            }
            guard let image = UIImage(data: data) else {
                dataPromise.fail(Error.unknown)
                return
            }
            self.cache?.store(publicImageURL: urlString, image: image)
            dataPromise.succeed(image)
        }.resume()
        return dataPromise.futureResult
    }

}
