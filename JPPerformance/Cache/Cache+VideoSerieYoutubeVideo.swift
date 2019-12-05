//
//  Cache+VideoSerieYoutubeVideo.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.VideoSerieYoutubeVideoRelation
    private var indexKey: String { "videoserieyoutubevideorelation-index" }
    private var indexStorage: DiskStorage<[CodableType]> { videoSerieYoutubeVideoRelationsStorage }
    private var singleStorage: DiskStorage<CodableType> { videoSerieYoutubeVideoRelationStorage }
    private func keyFor(codable: CodableType) -> String? {
        return nil
    }

    func store(videoSeriesYoutubeVideosIndex: [JPFanAppClient.VideoSerieYoutubeVideoRelation]) {
        store(index: videoSeriesYoutubeVideosIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedVideoSerieYoutubeVideosIndex() -> [JPFanAppClient.VideoSerieYoutubeVideoRelation]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

}
