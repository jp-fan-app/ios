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
    public func getCarModels() -> EventLoopFuture<[JPFanAppClient.CarModel]> {
        if let cached = cache?.cachedCarModelsIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.modelsIndex().map { index in
            self.cache?.store(carModelsIndex: index)
            return index
        }
    }

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

    public func getCarImageFile(id: Int) -> EventLoopFuture<Data> {
        if let cached = cache?.cachedCarImageData(carImageID: id) {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.imagesFile(id: id).map { data in
            self.cache?.store(carImageID: id, carImageData: data)
            return data
        }
    }

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
    public func getStageTimings() -> EventLoopFuture<[JPFanAppClient.StageTiming]> {
        if let cached = cache?.cachedStageTimingsIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.timingsIndex().map { index in
            self.cache?.store(stageTimingsIndex: index)
            return index
        }
    }

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
    public func getStagesVideos() -> EventLoopFuture<[JPFanAppClient.CarStageYoutubeVideoRelation]> {
        if let cached = cache?.cachedCarStageVideoRelationsIndex() {
            return httpClient.nextEventLoop().makeSucceededFuture(cached)
        }
        return httpClient.stagesVideosRelations().map { index in
            self.cache?.store(carStageVideoRelationsIndex: index)
            return index
        }
    }

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