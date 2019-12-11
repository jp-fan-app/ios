//
//  Cache+CarImages.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Cache
import Foundation


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

    func store(carImages: [JPFanAppClient.CarImage], carModelId: Int) {
        store(index: carImages,
              indexStorage: indexStorage,
              indexKey: "car-model-images-\(carModelId)",
              singleStorage: singleStorage,
              singleKey: keyFor)
    }

    func cachedCarImagesIndex() -> [JPFanAppClient.CarImage]? {
        return cachedIndex(in: indexStorage, key: indexKey)
    }

    func cachedCarImagesForCarModel(carModelId: Int) -> [JPFanAppClient.CarImage]? {
        return cachedIndex(in: indexStorage, key: "car-model-images-\(carModelId)")
    }

    func cached(carImageID: Int) -> JPFanAppClient.CarImage? {
        return cachedSingle(in: singleStorage, key: "\(carImageID)")
    }

    // MARK: - Car Image Data

    func store(carImageID: Int, carImageData: Data) {
        try? carImageDataStorage.setObject(carImageData, forKey: "\(carImageID)")
    }

    func cachedCarImageData(carImageID: Int) -> Data? {
        return try? carImageDataStorage.object(forKey: "\(carImageID)")
    }

}
