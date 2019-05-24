//
//  CarService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation


class CarService {
    
    public private(set) static var sharedInstance = CarService(staging: false)

    private var isStaging: Bool
    
    init(staging: Bool = false) {
        self.isStaging = staging
    }
    
    static func prepareForStaging() {
        sharedInstance = CarService(staging: true)
    }

    static func prepareForProduction() {
        sharedInstance = CarService(staging: false)
    }

    static func carItemFromCarModel(_ carModel: CarModel) -> JPCarItem? {
        guard let manufacturer = carModel.manufacturer else { return nil }
        guard let transmissionType = carModel.transmissionType() else { return nil }
        guard let axleType = carModel.axleType() else { return nil }

        let carItemTransmissionType: JPCarItem.TransmissionType
        switch transmissionType {
        case .automatic: carItemTransmissionType = .automatic
        case .manual: carItemTransmissionType = .manual
        }

        let carItemWheelType: JPCarItem.WheelType
        switch axleType {
        case .all: carItemWheelType = .all
        case .front: carItemWheelType = .front
        case .rear: carItemWheelType = .rear
        }

        let images = StorageService.shared.carImagesForCarModel(carModel).filter({ $0.hasUpload })
        var carImages: [JPCarImage] = []
        for image in images {
            let carImage = JPCarImage(id: image.id,
                                      isMainImage: carModel.mainImageID.value == image.id,
                                      copyrightInformation: image.copyrightInformation)
            carImages.append(carImage)
        }

        let stages = StorageService.shared.carStagesForCarModel(carModel)
        var carStages: [JPCarStage] = []
        for stage in stages {
            let timings = StorageService.shared.stageTimingsForCarStage(stage)
            var carStageTimings: [JPCarStageTiming] = []
            for timing in timings {
                let carStageTiming = JPCarStageTiming(range: timing.range,
                                                      seconds:
                [
                    timing.second1.value,
                    timing.second2.value,
                    timing.second3.value
                ])
                carStageTimings.append(carStageTiming)
            }

            let carStage = JPCarStage(title: stage.name,
                                      description: stage.stageDescription,
                                      isStock: stage.isStock,
                                      youtubeIDs: stage.videos.map({ $0.videoID }),
                                      timings: carStageTimings,
                                      ps: stage.ps.value,
                                      nm: stage.nm.value,
                                      lasiseInSeconds: stage.lasiseInSeconds.value)
            carStages.append(carStage)
        }

        return JPCarItem(carModelId: carModel.id,
                         manufacturer: manufacturer.name,
                         model: carModel.name,
                         transmission: carItemTransmissionType,
                         type: carItemWheelType,
                         images: carImages,
                         stages: carStages)
    }

    func fetchData(completion: @escaping (JPCarData?) -> Void) {
        let dispatchQueue = DispatchQueue(label: "fetchData",
                                          qos: .userInitiated,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .inherit,
                                          target: nil)
        dispatchQueue.async {
            var carItems: [JPCarItem] = []
            let allCarModels = StorageService.shared.allCarModels()
            for carModel in allCarModels {
                guard let carItem = CarService.carItemFromCarModel(carModel) else { continue }
                carItems.append(carItem)
            }
            let carData = JPCarData(cars: carItems)
            DispatchQueue.main.async {
                completion(carData)
            }
        }
    }

    /// Board with given range
    ///
    /// - Parameters:
    ///   - forRange: for example: 0-100 or 100-200
    func fetchBoard(forRange range: String, completion: @escaping (JPCarData?) -> Void) {
        fetchData { carData in
            DispatchQueue.global(qos: .background).async {
                guard let carData = carData else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                // collect all car items with given range
                let carItemsWithRange = carData.cars.filter({ carItem -> Bool in
                    carItem.stages.filter({ stage -> Bool in
                        stage.timings?.filter({ timing -> Bool in
                            return timing.range == range
                        }).count ?? 0 > 0
                    }).count > 0
                })

                let sortedCarItemsWithRange = carItemsWithRange.sorted(by: { (carItem1, carItem2) -> Bool in
                    return carItem1.bestStage(inRange: range)?.bestTiming(inRange: range)?.bestSecond() ?? 99999.0 < carItem2.bestStage(inRange: range)?.bestTiming(inRange: range)?.bestSecond() ?? 99999.0
                })

                let rangeCarData = JPCarData(cars: sortedCarItemsWithRange)
                DispatchQueue.main.async {
                    completion(rangeCarData)
                }
            }
        }
    }

    /// Board sorted by PS
    func fetchBoardForPS(completion: @escaping (JPCarData?) -> Void) {
        fetchData { carData in
            DispatchQueue.global(qos: .background).async {
                guard let carData = carData else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                // collect all car items with given ps
                let carItemsWithPS = carData.cars.filter({ carItem -> Bool in
                    carItem.stages.filter({ stage -> Bool in
                        return stage.ps != nil
                    }).count > 0
                })

                let sortedCarItemsWithPS = carItemsWithPS.sorted(by: { (carItem1, carItem2) -> Bool in
                    return carItem1.bestStageInPS()?.ps ?? 0.0 > carItem2.bestStageInPS()?.ps ?? 0.0
                })

                let rangeCarData = JPCarData(cars: sortedCarItemsWithPS)
                DispatchQueue.main.async {
                    completion(rangeCarData)
                }
            }
        }
    }

    /// Board sorted by NM
    func fetchBoardForNM(completion: @escaping (JPCarData?) -> Void) {
        fetchData { carData in
            DispatchQueue.global(qos: .background).async {
                guard let carData = carData else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                // collect all car items with given ps
                let carItemsWithNM = carData.cars.filter({ carItem -> Bool in
                    carItem.stages.filter({ stage -> Bool in
                        return stage.nm != nil
                    }).count > 0
                })

                let sortedCarItemsWithNM = carItemsWithNM.sorted(by: { (carItem1, carItem2) -> Bool in
                    return carItem1.bestStageInNM()?.nm ?? 0.0 > carItem2.bestStageInNM()?.nm ?? 0.0
                })

                let rangeCarData = JPCarData(cars: sortedCarItemsWithNM)
                DispatchQueue.main.async {
                    completion(rangeCarData)
                }
            }
        }
    }

    /// Board sorted by LaSiSe Seconds

    func fetchBoardForLaSiSe(completion: @escaping (JPCarData?) -> Void) {
        fetchData { carData in
            DispatchQueue.global(qos: .background).async {
                guard let carData = carData else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                // collect all car items with given ps
                let carItemsWithSeconds = carData.cars.filter({ carItem -> Bool in
                    carItem.stages.filter({ stage -> Bool in
                        return stage.lasiseInSeconds != nil
                    }).count > 0
                })

                let sortedCarItemsWithLaSiSeSeconds = carItemsWithSeconds.sorted(by: { (carItem1, carItem2) -> Bool in
                    let lasise1 = carItem1.bestStageInLaSiSe()?.lasiseInSeconds ?? 99999.0
                    let lasise2 = carItem2.bestStageInLaSiSe()?.lasiseInSeconds ?? 99999.0
                    return lasise1 < lasise2
                })

                let carDataWithLaSiSeSeconds = JPCarData(cars: sortedCarItemsWithLaSiSeSeconds)
                DispatchQueue.main.async {
                    completion(carDataWithLaSiSeSeconds)
                }
            }
        }
    }

}
