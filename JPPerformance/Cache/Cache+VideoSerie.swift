//
//  Cache+VideoSerie.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.VideoSerie
    private var indexKey: String { "videoseries-index" }
    private var indexStorage: DiskStorage<[CodableType]> { videoSeriesStorage }
    private var singleStorage: DiskStorage<CodableType> { videoSerieStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(videoSeriesIndex: [JPFanAppClient.VideoSerie]) {
        store(index: videoSeriesIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedVideoSeriesIndex() -> [JPFanAppClient.VideoSerie]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cached(videoSerieID: Int) -> JPFanAppClient.VideoSerie? {
        return cachedSingle(in: singleStorage, key: "\(videoSerieID)")
    }

}
