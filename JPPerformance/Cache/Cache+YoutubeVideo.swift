//
//  Cache+YoutubeVideo.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.YoutubeVideo
    private var indexKey: String { "youtubevideos-index" }
    private var indexStorage: DiskStorage<[CodableType]> { youtubeVideosStorage }
    private var singleStorage: DiskStorage<CodableType> { youtubeVideoStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(youtubeVideosIndex: [JPFanAppClient.YoutubeVideo]) {
        store(index: youtubeVideosIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func store(youtubeVideos: [JPFanAppClient.YoutubeVideo], forCarStage carStageId: Int) {
        store(index: youtubeVideos,
              indexStorage: indexStorage,
              indexKey: "car-stage-videos-\(carStageId)",
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedYoutubeVideosIndex() -> [JPFanAppClient.YoutubeVideo]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cachedCarStageVideos(carStageId: Int) -> [JPFanAppClient.YoutubeVideo]? {
        return cachedIndex(in: indexStorage, key: "car-stage-videos-\(carStageId)")
    }

    func cached(youtubeVideoID: Int) -> JPFanAppClient.YoutubeVideo? {
        return cachedSingle(in: singleStorage, key: "\(youtubeVideoID)")
    }

}
