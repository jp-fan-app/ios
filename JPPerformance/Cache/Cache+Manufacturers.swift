//
//  Cache+Manufacturers.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.ManufacturerModel
    private var indexKey: String { "manufacturers-index" }
    private var indexStorage: DiskStorage<[CodableType]> { manufacturersStorage }
    private var singleStorage: DiskStorage<CodableType> { manufacturerStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(manufacturersIndex: [JPFanAppClient.ManufacturerModel]) {
        store(index: manufacturersIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedManufacturersIndex() -> [JPFanAppClient.ManufacturerModel]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cached(manufacturerID: Int) -> JPFanAppClient.ManufacturerModel? {
        return cachedSingle(in: singleStorage, key: "\(manufacturerID)")
    }

}
