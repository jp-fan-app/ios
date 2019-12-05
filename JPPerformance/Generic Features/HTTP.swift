//
//  HTTP.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 04.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Foundation
import NIO
@_exported import JPFanAppClient


public class HTTP {

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

}
