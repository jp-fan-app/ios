//
//  Cache+StageTiming.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.StageTiming
    private var indexKey: String { "stagetimings-index" }
    private var indexStorage: DiskStorage<[CodableType]> { stageTimingsStorage }
    private var singleStorage: DiskStorage<CodableType> { stageTimingStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(stageTimingsIndex: [JPFanAppClient.StageTiming]) {
        store(index: stageTimingsIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedStageTimingsIndex() -> [JPFanAppClient.StageTiming]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cached(stageTimingID: Int) -> JPFanAppClient.StageTiming? {
        return cachedSingle(in: singleStorage, key: "\(stageTimingID)")
    }

}
