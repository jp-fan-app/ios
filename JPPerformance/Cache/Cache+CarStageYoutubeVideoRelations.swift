//
//  Cache+CarStageYoutubeVideoRelations.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.CarStageYoutubeVideoRelation
    private var indexKey: String { "carstagevideorelations-index" }
    private var indexStorage: DiskStorage<[CodableType]> { carStageVideoRelationsStorage }
    private var singleStorage: DiskStorage<CodableType> { carStageVideoRelationStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(carStageVideoRelationsIndex: [JPFanAppClient.CarStageYoutubeVideoRelation]) {
        store(index: carStageVideoRelationsIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedCarStageVideoRelationsIndex() -> [JPFanAppClient.CarStageYoutubeVideoRelation]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cached(cachedCarStageVideoRelationID: Int) -> JPFanAppClient.CarStageYoutubeVideoRelation? {
        return cachedSingle(in: singleStorage, key: "\(cachedCarStageVideoRelationID)")
    }

}
