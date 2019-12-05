//
//  Cache+CarImages.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache


public extension Cache {

    private typealias CodableType = JPFanAppClient.CarImage
    private var indexKey: String { "carimages-index" }
    private var indexStorage: DiskStorage<[CodableType]> { carImagesStorage }
    private var singleStorage: DiskStorage<CodableType> { carImageStorage }
    private func keyFor(codable: CodableType) -> String? {
        guard let id = codable.id else { return nil}
        return "\(id)"
    }

    func store(carImagesIndex: [JPFanAppClient.CarImage]) {
        store(index: carImagesIndex,
              indexStorage: indexStorage,
              indexKey: indexKey,
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedCarImagesIndex() -> [JPFanAppClient.CarImage]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cached(carImageID: Int) -> JPFanAppClient.CarImage? {
        return cachedSingle(in: singleStorage, key: "\(carImageID)")
    }

}
