//
//  JPCarData.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation
import SwiftyJSON


struct JPCarData {

    let cars: [JPCarItem]

    init(cars: [JPCarItem]) {
        self.cars = cars
    }

}


struct JPCarItem {

    enum TransmissionType: String {
        case manual
        case automatic
    }

    enum WheelType: String {
        case front
        case rear
        case all
    }

    let carModelId: Int
    let manufacturer: String
    let model: String
    let transmission: TransmissionType
    let type: WheelType
    let images: [JPCarImage]
    let stages: [JPCarStage]

    init(carModelId: Int,
         manufacturer: String,
         model: String,
         transmission: TransmissionType,
         type: WheelType,
         images: [JPCarImage],
         stages: [JPCarStage]) {
        self.carModelId = carModelId
        self.manufacturer = manufacturer
        self.model = model
        self.transmission = transmission
        self.type = type
        self.images = images
        self.stages = stages
    }

    func groupKey() -> String {
        return manufacturer.uppercased()
    }

    func mainImage() -> JPCarImage? {
        for image in images {
            if image.isMainImage {
                return image
            }
        }
        return images.first
    }

    func bestStage(inRange range: String) -> JPCarStage? {
        return stages.min(by: { (stage1, stage2) -> Bool in
            return stage1.bestTiming(inRange: range)?.bestSecond() ?? 99999.0 < stage2.bestTiming(inRange: range)?.bestSecond() ?? 99999.0
        })
    }

    func bestStageInPS() -> JPCarStage? {
        return stages.max(by: { (stage1, stage2) -> Bool in
            return stage1.ps ?? 0.0 < stage2.ps ?? 0.0
        })
    }

    func bestStageInNM() -> JPCarStage? {
        return stages.max(by: { (stage1, stage2) -> Bool in
            return stage1.nm ?? 0.0 < stage2.nm ?? 0.0
        })
    }

    func stages(inRange range: String) -> [JPCarStage] {
        return stages.filter({ $0.bestTiming(inRange: range) != nil })
    }

}


struct JPCarImage {

    let id: Int
    let isMainImage: Bool
    let copyrightInformation: String?

    init(id: Int,
         isMainImage: Bool,
         copyrightInformation: String) {
        self.id = id
        self.isMainImage = isMainImage
        self.copyrightInformation = copyrightInformation
    }

}


struct JPCarStage {

    let title: String
    let description: String
    let isStock: Bool
    let youtubeID: String?
    let timings: [JPCarStageTiming]?
    let ps: Double?
    let nm: Double?

    init(title: String,
         description: String,
         isStock: Bool,
         youtubeID: String?,
         timings: [JPCarStageTiming]?,
         ps: Double?,
         nm: Double?) {
        self.title = title
        self.description = description
        self.isStock = isStock
        self.youtubeID = youtubeID
        self.timings = timings
        self.ps = ps
        self.nm = nm
    }

    func displayDescription() -> String {
        if description.count > 0 {
            return description
        }
        return "no_description".localized()
    }

    func bestTiming(inRange range: String) -> JPCarStageTiming? {
        guard let timings = timings else { return nil }
        return timings.filter({ $0.range == range }).min { (timing1, timing2) -> Bool in
            return timing1.bestSecond() < timing2.bestSecond()
        }
    }

    func displayStringForPS() -> String? {
        guard let ps = ps else { return nil }
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        nf.minimumFractionDigits = 0
        guard let formattedPS = nf.string(from: NSNumber(value: ps)) else { return nil }
        return "\(formattedPS) PS"
    }

    func displayStringForNM() -> String? {
        guard let nm = nm else { return nil }
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        nf.minimumFractionDigits = 0
        guard let formattedNM = nf.string(from: NSNumber(value: nm)) else { return nil }
        return "\(formattedNM) NM"
    }

}


struct JPCarStageTiming {

    let range: String
    let seconds: [Double]

    init(range: String, seconds: [Double?]) {
        self.range = range
        self.seconds = seconds.compactMap { $0 }
    }

    func bestSecond() -> Double {
        return seconds.min() ?? 99999.0
    }

}
