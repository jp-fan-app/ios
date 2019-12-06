//
//  Cache.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 04.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Foundation
import Cache
import JPFanAppClient


public class Cache {

    internal let manufacturerStorage: DiskStorage<JPFanAppClient.ManufacturerModel>
    internal let manufacturersStorage: DiskStorage<[JPFanAppClient.ManufacturerModel]>

    internal let carModelStorage: DiskStorage<JPFanAppClient.CarModel>
    internal let carModelsStorage: DiskStorage<[JPFanAppClient.CarModel]>

    internal let carImageStorage: DiskStorage<JPFanAppClient.CarImage>
    internal let carImagesStorage: DiskStorage<[JPFanAppClient.CarImage]>
    internal let carImageDataStorage: DiskStorage<Data>

    internal let carStageStorage: DiskStorage<JPFanAppClient.CarStage>
    internal let carStagesStorage: DiskStorage<[JPFanAppClient.CarStage]>

    internal let stageTimingStorage: DiskStorage<JPFanAppClient.StageTiming>
    internal let stageTimingsStorage: DiskStorage<[JPFanAppClient.StageTiming]>

    internal let youtubeVideoStorage: DiskStorage<JPFanAppClient.YoutubeVideo>
    internal let youtubeVideosStorage: DiskStorage<[JPFanAppClient.YoutubeVideo]>

    internal let carStageVideoRelationStorage: DiskStorage<JPFanAppClient.CarStageYoutubeVideoRelation>
    internal let carStageVideoRelationsStorage: DiskStorage<[JPFanAppClient.CarStageYoutubeVideoRelation]>

    internal let videoSerieStorage: DiskStorage<JPFanAppClient.VideoSerie>
    internal let videoSeriesStorage: DiskStorage<[JPFanAppClient.VideoSerie]>

    internal let videoSerieYoutubeVideoRelationStorage: DiskStorage<JPFanAppClient.VideoSerieYoutubeVideoRelation>
    internal let videoSerieYoutubeVideoRelationsStorage: DiskStorage<[JPFanAppClient.VideoSerieYoutubeVideoRelation]>

    internal let publicImagesStorage: DiskStorage<Image>

    // swiftlint:disable line_length function_body_length
    public init?() {
        let oneDayExpiry = Expiry.seconds(60 * 60 * 24)
        let oneMonthExpiry = Expiry.seconds(60 * 60 * 24 * 30)

        let manufacturersConfig = DiskConfig(name: "manufacturers", expiry: oneDayExpiry)
        let carModelsConfig = DiskConfig(name: "car-models", expiry: oneDayExpiry)
        let carImagesConfig = DiskConfig(name: "car-images", expiry: oneDayExpiry)
        let carImageDataConfig = DiskConfig(name: "car-image-data", expiry: oneMonthExpiry)
        let carStagesConfig = DiskConfig(name: "car-stages", expiry: oneDayExpiry)
        let stageTimingConfig = DiskConfig(name: "stage-timings", expiry: oneDayExpiry)
        let youtubeVideosConfig = DiskConfig(name: "youtube-videos", expiry: oneDayExpiry)
        let stageVideosConfig = DiskConfig(name: "stage-videos", expiry: oneDayExpiry)
        let videoSeriesConfig = DiskConfig(name: "video-series", expiry: oneDayExpiry)
        let videoSeriesYoutubeVideoRelationsConfig = DiskConfig(name: "video-series-youtube-video-relations", expiry: oneDayExpiry)
        let publicImagesConfig = DiskConfig(name: "public-images", expiry: oneMonthExpiry)

        let manufacturerTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.ManufacturerModel.self)
        let manufacturersTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.ManufacturerModel].self)

        let carModelTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.CarModel.self)
        let carModelsTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.CarModel].self)

        let carImageTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.CarImage.self)
        let carImagesTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.CarImage].self)

        let carStageTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.CarStage.self)
        let carStagesTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.CarStage].self)

        let stageTimingTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.StageTiming.self)
        let stageTimingsTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.StageTiming].self)

        let youtubeVideoTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.YoutubeVideo.self)
        let youtubeVideosTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.YoutubeVideo].self)

        let carStageVideoRelationTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.CarStageYoutubeVideoRelation.self)
        let carStageVideoRelationsTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.CarStageYoutubeVideoRelation].self)

        let videoSerieTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.VideoSerie.self)
        let videoSeriesTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.VideoSerie].self)

        let videoSerieYoutubeVideoRelationTransformer = TransformerFactory.forCodable(ofType: JPFanAppClient.VideoSerieYoutubeVideoRelation.self)
        let videoSerieYoutubeVideoRelationsTransformer = TransformerFactory.forCodable(ofType: [JPFanAppClient.VideoSerieYoutubeVideoRelation].self)

        guard let manufacturerStorage = try? DiskStorage(config: manufacturersConfig, transformer: manufacturerTransformer),
            let manufacturersStorage = try? DiskStorage(config: manufacturersConfig, transformer: manufacturersTransformer),
            let carModelStorage = try? DiskStorage(config: carModelsConfig, transformer: carModelTransformer),
            let carModelsStorage = try? DiskStorage(config: carModelsConfig, transformer: carModelsTransformer),

            let carImageStorage = try? DiskStorage(config: carImagesConfig, transformer: carImageTransformer),
            let carImagesStorage = try? DiskStorage(config: carImagesConfig, transformer: carImagesTransformer),

            let carImageDataStorage = try? DiskStorage(config: carImageDataConfig, transformer: TransformerFactory.forData()),

            let carStageStorage = try? DiskStorage(config: carStagesConfig, transformer: carStageTransformer),
            let carStagesStorage = try? DiskStorage(config: carStagesConfig, transformer: carStagesTransformer),

            let stageTimingStorage = try? DiskStorage(config: stageTimingConfig, transformer: stageTimingTransformer),
            let stageTimingsStorage = try? DiskStorage(config: stageTimingConfig, transformer: stageTimingsTransformer),

            let youtubeVideoStorage = try? DiskStorage(config: youtubeVideosConfig, transformer: youtubeVideoTransformer),
            let youtubeVideosStorage = try? DiskStorage(config: youtubeVideosConfig, transformer: youtubeVideosTransformer),

            let carStageVideoRelationStorage = try? DiskStorage(config: stageVideosConfig, transformer: carStageVideoRelationTransformer),
            let carStageVideoRelationsStorage = try? DiskStorage(config: stageVideosConfig, transformer: carStageVideoRelationsTransformer),

            let videoSerieStorage = try? DiskStorage(config: videoSeriesConfig, transformer: videoSerieTransformer),
            let videoSeriesStorage = try? DiskStorage(config: videoSeriesConfig, transformer: videoSeriesTransformer),

            let videoSerieYoutubeVideoRelationStorage = try? DiskStorage(config: videoSeriesYoutubeVideoRelationsConfig, transformer: videoSerieYoutubeVideoRelationTransformer),
            let videoSerieYoutubeVideoRelationsStorage = try? DiskStorage(config: videoSeriesYoutubeVideoRelationsConfig, transformer: videoSerieYoutubeVideoRelationsTransformer),

            let publicImagesStorage = try? DiskStorage(config: publicImagesConfig, transformer: TransformerFactory.forImage())
        else {
            return nil
        }

        self.manufacturerStorage = manufacturerStorage
        self.manufacturersStorage = manufacturersStorage
        self.carModelStorage = carModelStorage
        self.carModelsStorage = carModelsStorage
        self.carImageStorage = carImageStorage
        self.carImagesStorage = carImagesStorage
        self.carImageDataStorage = carImageDataStorage
        self.carStageStorage = carStageStorage
        self.carStagesStorage = carStagesStorage
        self.stageTimingStorage = stageTimingStorage
        self.stageTimingsStorage = stageTimingsStorage
        self.youtubeVideoStorage = youtubeVideoStorage
        self.youtubeVideosStorage = youtubeVideosStorage
        self.carStageVideoRelationStorage = carStageVideoRelationStorage
        self.carStageVideoRelationsStorage = carStageVideoRelationsStorage
        self.videoSerieStorage = videoSerieStorage
        self.videoSeriesStorage = videoSeriesStorage
        self.videoSerieYoutubeVideoRelationStorage = videoSerieYoutubeVideoRelationStorage
        self.videoSerieYoutubeVideoRelationsStorage = videoSerieYoutubeVideoRelationsStorage
        self.publicImagesStorage = publicImagesStorage

        try? manufacturerStorage.removeExpiredObjects()
        try? manufacturersStorage.removeExpiredObjects()
        try? carModelStorage.removeExpiredObjects()
        try? carModelsStorage.removeExpiredObjects()
        try? carImageStorage.removeExpiredObjects()
        try? carImagesStorage.removeExpiredObjects()
        try? carImageDataStorage.removeExpiredObjects()
        try? carStageStorage.removeExpiredObjects()
        try? carStagesStorage.removeExpiredObjects()
        try? stageTimingStorage.removeExpiredObjects()
        try? stageTimingsStorage.removeExpiredObjects()
        try? youtubeVideoStorage.removeExpiredObjects()
        try? youtubeVideosStorage.removeExpiredObjects()
        try? carStageVideoRelationStorage.removeExpiredObjects()
        try? carStageVideoRelationsStorage.removeExpiredObjects()
        try? videoSerieStorage.removeExpiredObjects()
        try? videoSeriesStorage.removeExpiredObjects()
        try? videoSerieYoutubeVideoRelationStorage.removeExpiredObjects()
        try? videoSerieYoutubeVideoRelationsStorage.removeExpiredObjects()
        try? publicImagesStorage.removeExpiredObjects()

//        #if DEBUG
//        let cacheURL = URL(fileURLWithPath: manufacturerStorage.path).deletingLastPathComponent()
//        print("Cache: \(cacheURL.path)")
//        #endif
    }
    // swiftlint:enable line_length function_body_length

    internal func store<CodableType: Codable>(index: [CodableType],
                                              indexStorage: DiskStorage<[CodableType]>,
                                              indexKey: String,
                                              singleStorage: DiskStorage<CodableType>,
                                              singleKey: ((CodableType) -> String?)) {
        try? indexStorage.setObject(index, forKey: indexKey)
        for single in index {
            store(single: single, storage: singleStorage, key: singleKey(single))
        }
    }

    internal func store<CodableType: Codable>(single: CodableType, storage: DiskStorage<CodableType>, key: String?) {
        guard let key = key else { return }
        try? storage.setObject(single, forKey: key)
    }

    internal func cachedIndex<CodableType: Codable>(in storage: DiskStorage<[CodableType]>,
                                                    key: String) -> [CodableType]? {
        return try? storage.object(forKey: key)
    }

    internal func cachedSingle<CodableType: Codable>(in storage: DiskStorage<CodableType>,
                                                     key: String) -> CodableType? {
        return try? storage.object(forKey: key)
    }

}
