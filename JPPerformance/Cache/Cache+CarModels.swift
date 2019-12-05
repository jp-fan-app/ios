//
//  Cache+CarModels.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.CarModel
    private var indexKey: String { "carmodels-index" }
    private var indexStorage: DiskStorage<[CodableType]> { carModelsStorage }
    private var singleStorage: DiskStorage<CodableType> { carModelStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(carModelsIndex: [JPFanAppClient.CarModel]) {
        store(index: carModelsIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedCarModelsIndex() -> [JPFanAppClient.CarModel]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cached(carModelID: Int) -> JPFanAppClient.CarModel? {
        return cachedSingle(in: singleStorage, key: "\(carModelID)")
    }

}
