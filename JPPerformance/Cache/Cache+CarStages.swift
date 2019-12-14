//
//  Cache+CarStages.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.CarStage
    private var indexKey: String { "carstages-index" }
    private var indexStorage: DiskStorage<[CodableType]> { carStagesStorage }
    private var singleStorage: DiskStorage<CodableType> { carStageStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(carStagesIndex: [JPFanAppClient.CarStage]) {
        store(index: carStagesIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func store(carStages: [JPFanAppClient.CarStage], forCarModelId carModelId: Int) {
        store(index: carStages,
              indexStorage: indexStorage,
              indexKey: "car-model-stages-\(carModelId)",
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedCarStagesIndex() -> [JPFanAppClient.CarStage]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cachedCarStagesForCarModel(carModelId: Int) -> [JPFanAppClient.CarStage]? {
        return cachedIndex(in: indexStorage, key: "car-model-stages-\(carModelId)")
    }

    func cached(carStageID: Int) -> JPFanAppClient.CarStage? {
        return cachedSingle(in: singleStorage, key: "\(carStageID)")
    }

}
