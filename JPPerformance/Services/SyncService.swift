//
//  SyncService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 19.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import JPFanAppClient

// swiftlint:disable type_body_length file_length
public class SyncService {

    public static let shared = SyncService()

    public private(set) var isSyncing: Bool = false

    public static let didUpdateManufacturersNotification = Notification.Name(rawValue: "didUpdateManufacturersNotification")
    public static let didUpdateModelsNotification = Notification.Name(rawValue: "didUpdateModelsNotification")
    public static let didUpdateAllRelationsForCarModelNotification = Notification.Name(rawValue: "didUpdateAllRelationsForCarModelNotification")
    public static let didUpdateImagesNotification = Notification.Name(rawValue: "didUpdateImagesNotification")
    public static let didUpdateStagesNotification = Notification.Name(rawValue: "didUpdateStagesNotification")
    public static let didUpdateTimingsNotification = Notification.Name(rawValue: "didUpdateTimingsNotification")
    public static let didUpdateVideosNotification = Notification.Name(rawValue: "didUpdateVideosNotification")
    public static let didUpdateStagesVideosNotification = Notification.Name(rawValue: "didUpdateStagesVideosNotification")
    public static let didUpdateVideoSeriesNotification = Notification.Name(rawValue: "didUpdateVideoSeriesNotification")
    public static let didUpdateVideoSeriesVideosNotification = Notification.Name(rawValue: "didUpdateVideoSeriesVideosNotification")

    private let manufacturerLock = NSLock()
    private let carModelLock = NSLock()
    private let imageLock = NSLock()
    private let stageLock = NSLock()
    private let timingLock = NSLock()
    private let videoLock = NSLock()
    private let videoSerieLock = NSLock()

    public private(set) var syncProgress: Progress = Progress(totalUnitCount: 0)
    public static let didUpdateProgressNotification = Notification.Name(rawValue: "didUpdateProgressNotification")

    private func sendDidUpdateProgressNotification() {
        NotificationCenter.default.post(name: SyncService.didUpdateProgressNotification, object: nil)
    }

    public func synchronizeIfNeeded() {
        var syncIsNeeded = false
        if let lastSync = Preferences.lastSync {
            let maxSyncAge = lastSync.add(components: [
                Calendar.Component.day : 2
            ])
            syncIsNeeded = Date() > maxSyncAge
        } else {
            syncIsNeeded = true
        }

        if syncIsNeeded {
            synchronize()
        }
    }

    public func synchronize() {
        guard !isSyncing else { return }
        isSyncing = true

        let dispatchQueue = DispatchQueue(label: "synchronize",
                                          qos: .background,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .inherit,
                                          target: nil)
        dispatchQueue.async {
            print("sync start")

            self.syncProgress = Progress(totalUnitCount: 9)
            self.sendDidUpdateProgressNotification()

            // Manufacturer
            let manufacturerProgress = Progress()
            self.syncProgress.addChild(manufacturerProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeManufacturersSync(progress: manufacturerProgress)
            print("manufacturers done")
            NotificationCenter.default.post(name: SyncService.didUpdateManufacturersNotification, object: nil)

            // Car Models
            let carModelProgress = Progress()
            self.syncProgress.addChild(carModelProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeCarModelsSync(progress: carModelProgress)
            print("models done")
            NotificationCenter.default.post(name: SyncService.didUpdateModelsNotification, object: nil)

            // Car Image
            let carImageProgress = Progress()
            self.syncProgress.addChild(carImageProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeCarImagesSync(progress: carImageProgress)
            print("images done")
            NotificationCenter.default.post(name: SyncService.didUpdateImagesNotification, object: nil)

            // Car Stage
            let carStageProgress = Progress()
            self.syncProgress.addChild(carStageProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeCarStagesSync(progress: carStageProgress)
            print("stages done")
            NotificationCenter.default.post(name: SyncService.didUpdateStagesNotification, object: nil)

            // Stage Timing
            let stageTimingProgress = Progress()
            self.syncProgress.addChild(stageTimingProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeStageTimingsSync(progress: stageTimingProgress)
            print("timings done")
            NotificationCenter.default.post(name: SyncService.didUpdateTimingsNotification, object: nil)

            // Youtube Video
            let youtubeVideoProgress = Progress()
            self.syncProgress.addChild(youtubeVideoProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeYoutubeVideosSync(progress: youtubeVideoProgress)
            print("videos done")
            NotificationCenter.default.post(name: SyncService.didUpdateVideosNotification, object: nil)

            // Stage Video
            let stageVideoProgress = Progress()
            self.syncProgress.addChild(stageVideoProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeCarStagesWithVideosSync(progress: stageVideoProgress)
            print("stages videos relation done")
            NotificationCenter.default.post(name: SyncService.didUpdateStagesVideosNotification, object: nil)

            // Video Serie
            let videoSerieProgress = Progress()
            self.syncProgress.addChild(videoSerieProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeVideoSeriesSync(progress: videoSerieProgress)
            print("video series done")
            NotificationCenter.default.post(name: SyncService.didUpdateVideoSeriesNotification, object: nil)

            // VideoSerie Video
            let videoSerieVideoProgress = Progress()
            self.syncProgress.addChild(videoSerieVideoProgress, withPendingUnitCount: 1)
            self.sendDidUpdateProgressNotification()
            self.synchronizeVideoSeriesWithVideosSync(progress: videoSerieVideoProgress)
            print("video series videos relation done")
            NotificationCenter.default.post(name: SyncService.didUpdateVideoSeriesVideosNotification, object: nil)

            YoutubeService.shared.indexVideosForSpotlight()
            print("spotlight index done")
            print("sync done")

            Preferences.lastSync = Date()

            self.isSyncing = false
            self.sendDidUpdateProgressNotification()
        }
    }

    // MARK: - Car Information

    public func synchronizeCarInformation(completion: @escaping () -> Void) {
        guard !isSyncing else { return }
        isSyncing = true

        let dispatchQueue = DispatchQueue(label: "synchronizeCarInformation",
                                          qos: .background,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .inherit,
                                          target: nil)
        dispatchQueue.async {
            self.syncProgress = Progress(totalUnitCount: 6)
            self.sendDidUpdateProgressNotification()

            // Manufacturer
            let manufacturerProgress = Progress(totalUnitCount: 1)
            self.syncProgress.addChild(manufacturerProgress, withPendingUnitCount: 1)
            self.synchronizeManufacturersSync(progress: manufacturerProgress)
            print("manufacturers done")
            NotificationCenter.default.post(name: SyncService.didUpdateManufacturersNotification, object: nil)

            // Car Model
            let carModelProgress = Progress(totalUnitCount: 1)
            self.syncProgress.addChild(carModelProgress, withPendingUnitCount: 1)
            self.synchronizeCarModelsSync(progress: carModelProgress)
            print("models done")
            NotificationCenter.default.post(name: SyncService.didUpdateModelsNotification, object: nil)

            // Car Image
            let carImageProgress = Progress(totalUnitCount: 1)
            self.syncProgress.addChild(carImageProgress, withPendingUnitCount: 1)
            self.synchronizeCarImagesSync(progress: carImageProgress)
            print("images done")
            NotificationCenter.default.post(name: SyncService.didUpdateImagesNotification, object: nil)

            // Car Stage
            let carStageProgress = Progress(totalUnitCount: 1)
            self.syncProgress.addChild(carStageProgress, withPendingUnitCount: 1)
            self.synchronizeCarStagesSync(progress: carStageProgress)
            print("stages done")
            NotificationCenter.default.post(name: SyncService.didUpdateStagesNotification, object: nil)

            // Stage Timing
            let stageTimingProgress = Progress(totalUnitCount: 1)
            self.syncProgress.addChild(stageTimingProgress, withPendingUnitCount: 1)
            self.synchronizeStageTimingsSync(progress: stageTimingProgress)
            print("timings done")
            NotificationCenter.default.post(name: SyncService.didUpdateTimingsNotification, object: nil)

            // Stage Video
            let stageVideoProgress = Progress(totalUnitCount: 1)
            self.syncProgress.addChild(stageVideoProgress, withPendingUnitCount: 1)
            self.synchronizeCarStagesWithVideosSync(progress: stageVideoProgress)
            print("stages videos relation done")
            NotificationCenter.default.post(name: SyncService.didUpdateStagesVideosNotification, object: nil)

            self.isSyncing = false
            self.sendDidUpdateProgressNotification()

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    // MARK: - Manufacturer

    private func synchronizeManufacturersSync(progress: Progress?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var manufacturers: [JPFanAppClient.ManufacturerModel] = []
        HTTPService.shared.manufacturers { asyncManufacturers in
            if let asyncManufacturers = asyncManufacturers {
                manufacturers.append(contentsOf: asyncManufacturers)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        if manufacturers.count == 0 {
            print("no manufacturers from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        progress?.totalUnitCount = Int64(manufacturers.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for manufacturer in manufacturers {
            synchronizeManufacturerModelFromService(manufacturer)

            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        let ids = manufacturers.compactMap({ $0.id })
        StorageService.shared.deleteManufacturersExceptIDs(ids)
    }

    public func synchronizeSingleManufacturer(id: Int,
                                              completion: @escaping (ManufacturerModel?) -> Void) {
        HTTPService.shared.manufacturerShow(id: id) { manufacturerFromService in
            guard let manufacturerFromService = manufacturerFromService else {
                completion(nil)
                return
            }

            let manufacturerModel = self.synchronizeManufacturerModelFromService(manufacturerFromService)
            completion(manufacturerModel)
        }
    }

    @discardableResult
    private func synchronizeManufacturerModelFromService(_ manufacturerModelFromService: JPFanAppClient.ManufacturerModel) -> ManufacturerModel? {
        guard let id = manufacturerModelFromService.id else { return nil }

        manufacturerLock.lock()
        let createNew: Bool
        let manufacturerModel: ManufacturerModel
        if let existing = StorageService.shared.manufacturerWithID(id) {
            manufacturerModel = existing
            createNew = false
        } else {
            manufacturerModel = ManufacturerModel()
            manufacturerModel.id = id
            createNew = true
        }
        StorageService.shared.write { realm in
            manufacturerModel.name = manufacturerModelFromService.name
            manufacturerModel.createdAt = manufacturerModelFromService.createdAt
            manufacturerModel.updatedAt = manufacturerModelFromService.updatedAt
            if createNew {
                realm.add(manufacturerModel)
            }
        }
        manufacturerLock.unlock()

        return manufacturerModel
    }

    // MARK: - Car Model

    private func synchronizeCarModelsSync(progress: Progress?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var carModels: [JPFanAppClient.CarModel] = []
        HTTPService.shared.carModels { asyncCarModel in
            if let asyncCarModel = asyncCarModel {
                carModels.append(contentsOf: asyncCarModel)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        if carModels.count == 0 {
            print("no carModels from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        progress?.totalUnitCount = Int64(carModels.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for carModelFromService in carModels {
            synchronizeCarModelFromService(carModelFromService)
            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        let ids = carModels.compactMap({ $0.id })
        StorageService.shared.deleteCarModelsExceptIDs(ids)
    }

    public func synchronizeSingleCarModel(id: Int,
                                          includingRelations: Bool = false,
                                          completion: @escaping (CarModel?) -> Void) {
        HTTPService.shared.carModelShow(id: id) { carModelFromService in
            guard let carModelFromService = carModelFromService else {
                completion(nil)
                return
            }

            let syncCarModelBlock = {
                let carModel = self.synchronizeCarModelFromService(carModelFromService)
                completion(carModel)

                if includingRelations {
                    self.synchronizeAllRelationsForCarModel(id: id)
                }
            }

            // check manufacturer
            if StorageService.shared.manufacturerWithID(carModelFromService.manufacturerID) == nil {
                // synchronize manufacturer
                self.synchronizeSingleManufacturer(id: carModelFromService.manufacturerID) { _ in
                    syncCarModelBlock()
                }
            } else {
                syncCarModelBlock()
            }
        }
    }

    public func synchronizeAllRelationsForCarModel(id: Int,
                                                   completion: (() -> Void)? = nil) {
        let dispatchQueue = DispatchQueue(label: "synchronizeAllRelationsForCarModel",
                                          qos: .background,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .inherit,
                                          target: nil)
        dispatchQueue.async {
            let dispatchGroup = DispatchGroup()

            dispatchGroup.enter()
            HTTPService.shared.carModelImages(id: id) { images in
                self.synchronizeCarImagesSync(progress: nil, images: images)
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            HTTPService.shared.carModelStages(id: id) { stages in
                self.synchronizeCarStagesSync(progress: nil,stages: stages)

                if let stageIDs = stages?.compactMap({ $0.id }) {
                    // synchronize timings for all stages from car model
                    dispatchGroup.enter()
                    HTTPService.shared.timings(completion: { timings in
                        if let timingsForStagesFromCarModel = timings?.filter({ stageTiming in
                            return stageIDs.contains(stageTiming.stageID)
                        }) {
                            self.synchronizeStageTimingsSync(progress: nil,timings: timingsForStagesFromCarModel)
                        }
                        dispatchGroup.leave()
                    })
                }

                // leave for stages
                dispatchGroup.leave()
            }

            dispatchGroup.wait()
            DispatchQueue.main.async {
                completion?()
                NotificationCenter.default.post(name: SyncService.didUpdateAllRelationsForCarModelNotification,
                                                object: nil,
                                                userInfo: ["id": id])
            }
        }
    }

    @discardableResult
    private func synchronizeCarModelFromService(_ carModelFromService: JPFanAppClient.CarModel) -> CarModel? {
        guard let id = carModelFromService.id else { return nil }

        carModelLock.lock()
        let createNew: Bool
        let carModel: CarModel
        if let existing = StorageService.shared.carModelWithID(id) {
            carModel = existing
            createNew = false
        } else {
            carModel = CarModel()
            carModel.id = id
            createNew = true
        }
        StorageService.shared.write { realm in
            carModel.name = carModelFromService.name
            carModel.transmissionTypeInt = carModelFromService.transmissionType.rawValue
            carModel.axleTypeInt = carModelFromService.axleType.rawValue
            carModel.manufacturer = StorageService.shared.manufacturerWithID(carModelFromService.manufacturerID, realm: realm)
            carModel.mainImageID.value = carModelFromService.mainImageID
            carModel.createdAt = carModelFromService.createdAt
            carModel.updatedAt = carModelFromService.updatedAt
            if createNew {
                realm.add(carModel)
            }
        }
        carModelLock.unlock()

        return carModel
    }

    // MARK: - Car Images

    private func synchronizeCarImagesSync(progress: Progress?, images: [JPFanAppClient.CarImage]? = nil) {
        var carImages: [JPFanAppClient.CarImage] = []

        if let images = images {
            // use given images
            carImages = images
        } else {
            // load all images
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            HTTPService.shared.carImages { asyncCarImages in
                if let asyncCarImages = asyncCarImages {
                    carImages.append(contentsOf: asyncCarImages)
                }
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }

        if carImages.count == 0 {
            print("no carImages from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        progress?.totalUnitCount = Int64(carImages.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for carImageFromService in carImages {
            guard let id = carImageFromService.id else { continue }

            imageLock.lock()
            let createNew: Bool
            let carImage: CarImage
            if let existing = StorageService.shared.carImageWithID(id) {
                carImage = existing
                createNew = false
            } else {
                carImage = CarImage()
                carImage.id = id
                createNew = true
            }
            StorageService.shared.write { realm in
                carImage.copyrightInformation = carImageFromService.copyrightInformation
                carImage.hasUpload = carImageFromService.hasUpload
                carImage.carModel = StorageService.shared.carModelWithID(carImageFromService.carModelID, realm: realm)
                carImage.createdAt = carImageFromService.createdAt
                carImage.updatedAt = carImageFromService.updatedAt
                if createNew {
                    realm.add(carImage)
                }
            }
            imageLock.unlock()

            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        let ids = carImages.compactMap({ $0.id })
        StorageService.shared.deleteCarImagesExceptIDs(ids)
    }

    // MARK: - Car Stages

    private func synchronizeCarStagesSync(progress: Progress?, stages: [JPFanAppClient.CarStage]? = nil) {
        var carStages: [JPFanAppClient.CarStage] = []

        if let stages = stages {
            carStages = stages
        } else {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            HTTPService.shared.carStages { asyncCarStage in
                if let asyncCarStage = asyncCarStage {
                    carStages.append(contentsOf: asyncCarStage)
                }
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }

        if carStages.count == 0 {
            print("no carStages from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }

            return
        }

        progress?.totalUnitCount = Int64(carStages.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for carStageFromService in carStages {
            guard let id = carStageFromService.id else { continue }

            stageLock.lock()
            let createNew: Bool
            let carStage: CarStage
            if let existing = StorageService.shared.carStageWithID(id) {
                carStage = existing
                createNew = false
            } else {
                carStage = CarStage()
                carStage.id = id
                createNew = true
            }
            StorageService.shared.write { realm in
                carStage.name = carStageFromService.name
                carStage.stageDescription = carStageFromService.description
                carStage.isStock = carStageFromService.isStock
                carStage.carModel = StorageService.shared.carModelWithID(carStageFromService.carModelID, realm: realm)
                carStage.ps.value = carStageFromService.ps
                carStage.nm.value = carStageFromService.nm
                carStage.createdAt = carStageFromService.createdAt
                carStage.updatedAt = carStageFromService.updatedAt
                if createNew {
                    realm.add(carStage)
                }
            }
            stageLock.unlock()

            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        let ids = carStages.compactMap({ $0.id })
        StorageService.shared.deleteCarStagesExceptIDs(ids)
    }

    // MARK: - Timings

    private func synchronizeStageTimingsSync(progress: Progress?, timings: [JPFanAppClient.StageTiming]? = nil) {
        var stageTimings: [JPFanAppClient.StageTiming] = []

        if let timings = timings {
            stageTimings = timings
        } else {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            HTTPService.shared.timings { asyncStageTiming in
                if let asyncStageTiming = asyncStageTiming {
                    stageTimings.append(contentsOf: asyncStageTiming)
                }
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }

        if stageTimings.count == 0 {
            print("no stageTimings from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        progress?.totalUnitCount = Int64(stageTimings.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for stageTimingFromService in stageTimings {
            guard let id = stageTimingFromService.id else { continue }

            timingLock.lock()
            let createNew: Bool
            let stageTiming: StageTiming
            if let existing = StorageService.shared.stageTimingWithID(id) {
                stageTiming = existing
                createNew = false
            } else {
                stageTiming = StageTiming()
                stageTiming.id = id
                createNew = true
            }
            StorageService.shared.write { realm in
                stageTiming.range = stageTimingFromService.range
                stageTiming.second1.value = stageTimingFromService.second1
                stageTiming.second2.value = stageTimingFromService.second2
                stageTiming.second3.value = stageTimingFromService.second3
                stageTiming.carStage = StorageService.shared.carStageWithID(stageTimingFromService.stageID, realm: realm)
                stageTiming.createdAt = stageTimingFromService.createdAt
                stageTiming.updatedAt = stageTimingFromService.updatedAt
                if createNew {
                    realm.add(stageTiming)
                }
            }
            timingLock.unlock()

            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        let ids = stageTimings.compactMap({ $0.id })
        StorageService.shared.deleteStageTimingExceptIDs(ids)
    }

    // MARK: - Youtube Videos

    public func synchronizeYoutubeVideos(completion: @escaping () -> Void) {
        let dispatchQueue = DispatchQueue(label: "synchronizeYoutubeVideos",
                                          qos: .background,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .inherit,
                                          target: nil)
        dispatchQueue.async {
            self.synchronizeYoutubeVideosSync(progress: nil)
            NotificationCenter.default.post(name: SyncService.didUpdateVideosNotification, object: nil)
            YoutubeService.shared.indexVideosForSpotlight()

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func synchronizeYoutubeVideosSync(progress: Progress?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var youtubeVideos: [JPFanAppClient.YoutubeVideo] = []
        HTTPService.shared.videos { asyncYoutubeVideos in
            if let asyncYoutubeVideos = asyncYoutubeVideos {
                youtubeVideos.append(contentsOf: asyncYoutubeVideos)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        if youtubeVideos.count == 0 {
            print("no youtubeVideos from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        progress?.totalUnitCount = Int64(youtubeVideos.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for youtubeVideoFromService in youtubeVideos {
            synchronizeYoutubeVideoFromService(youtubeVideoFromService)
            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        let ids = youtubeVideos.compactMap({ $0.id })
        StorageService.shared.deleteYoutubeVideosExceptIDs(ids)
    }

    public func synchronizeSingleYoutubeVideo(id: Int, completion: @escaping (YoutubeVideoModel?) -> Void) {
        HTTPService.shared.videoShow(id: id) { video in
            guard let video = video else {
                completion(nil)
                return
            }

            let videoModel = self.synchronizeYoutubeVideoFromService(video)
            completion(videoModel)
        }
    }

    @discardableResult
    private func synchronizeYoutubeVideoFromService(_ youtubeVideoFromService: JPFanAppClient.YoutubeVideo) -> YoutubeVideoModel? {
        guard let id = youtubeVideoFromService.id else { return nil }

        videoLock.lock()
        let createNew: Bool
        let youtubeVideoModel: YoutubeVideoModel
        if let existing = StorageService.shared.youtubeVideoWithID(id) {
            youtubeVideoModel = existing
            createNew = false
        } else {
            youtubeVideoModel = YoutubeVideoModel()
            youtubeVideoModel.id = id
            createNew = true
        }
        StorageService.shared.write { realm in
            youtubeVideoModel.title = youtubeVideoFromService.title
            youtubeVideoModel.videoDescription = youtubeVideoFromService.description
            youtubeVideoModel.videoID = youtubeVideoFromService.videoID
            youtubeVideoModel.thumbnailURL = youtubeVideoFromService.thumbnailURL
            youtubeVideoModel.publishedAt = youtubeVideoFromService.publishedAt
            youtubeVideoModel.createdAt = youtubeVideoFromService.createdAt
            youtubeVideoModel.updatedAt = youtubeVideoFromService.updatedAt
            if createNew {
                realm.add(youtubeVideoModel)
            }
        }
        videoLock.unlock()

        return youtubeVideoModel
    }

    // MARK: - Car Stages / Videos

    private func synchronizeCarStagesWithVideosSync(progress: Progress?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var relations: [JPFanAppClient.CarStageYoutubeVideoRelation] = []
        HTTPService.shared.stagesVideosRelations { asyncRelations in
            if let asyncRelations = asyncRelations {
                relations.append(contentsOf: asyncRelations)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        if relations.count == 0 {
            print("no relations from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        let allCarStages = StorageService.shared.allCarStages()
        progress?.totalUnitCount = Int64(allCarStages.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for stage in allCarStages {
            let relationsForStage = relations.filter({ $0.carStageID == stage.id })
            StorageService.shared.write { realm in
                stage.videos.removeAll()

                for relation in relationsForStage {
                    guard let video = StorageService.shared.youtubeVideoWithID(relation.youtubeVideoID, realm: realm) else {
                        print("could not find related video \(relation.youtubeVideoID)")
                        continue
                    }
                    stage.videos.append(video)
                }
            }

            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }
    }

    // MARK: - Video Series

    public func synchronizeVideoSeries(completion: @escaping () -> Void) {
        let dispatchQueue = DispatchQueue(label: "synchronizeVideoSeries",
                                          qos: .background,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .inherit,
                                          target: nil)
        dispatchQueue.async {
            self.synchronizeVideoSeriesSync(progress: nil)
            self.synchronizeVideoSeriesWithVideosSync(progress: nil)
            NotificationCenter.default.post(name: SyncService.didUpdateVideoSeriesNotification, object: nil)
            NotificationCenter.default.post(name: SyncService.didUpdateVideoSeriesVideosNotification, object: nil)

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func synchronizeVideoSeriesSync(progress: Progress?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var videoSeries: [JPFanAppClient.VideoSerie] = []
        HTTPService.shared.videoSeries { asyncVideoSeries in
            if let asyncVideoSeries = asyncVideoSeries {
                videoSeries.append(contentsOf: asyncVideoSeries)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        if videoSeries.count == 0 {
            print("no videoSeries from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        progress?.totalUnitCount = Int64(videoSeries.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for videoSerieFromService in videoSeries {
            guard let id = videoSerieFromService.id else { continue }

            videoSerieLock.lock()
            let createNew: Bool
            let videoSerie: VideoSerie
            if let existing = StorageService.shared.videoSerieWithID(id) {
                videoSerie = existing
                createNew = false
            } else {
                videoSerie = VideoSerie()
                videoSerie.id = id
                createNew = true
            }
            StorageService.shared.write { realm in
                videoSerie.title = videoSerieFromService.title
                videoSerie.videoSerieDescription = videoSerieFromService.description
                videoSerie.isPublic = videoSerieFromService.isPublic

                videoSerie.createdAt = videoSerieFromService.createdAt
                videoSerie.updatedAt = videoSerieFromService.updatedAt
                if createNew {
                    realm.add(videoSerie)
                }
            }
            videoSerieLock.unlock()

            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        let ids = videoSeries.compactMap({ $0.id })
        StorageService.shared.deleteVideoSeriesExceptIDs(ids)
    }

    // MARK: - Video Series - Videos

    private func synchronizeVideoSeriesWithVideosSync(progress: Progress?) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var relations: [JPFanAppClient.VideoSerieYoutubeVideoRelation] = []
        HTTPService.shared.videoSeriesVideosRelations { asyncRelations in
            if let asyncRelations = asyncRelations {
                relations.append(contentsOf: asyncRelations)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        if relations.count == 0 {
            print("no relations from service")
            progress?.totalUnitCount = 0
            progress?.completedUnitCount = 0
            if progress != nil { sendDidUpdateProgressNotification() }
            return
        }

        let allVideoSeries = StorageService.shared.allVideoSeries()
        progress?.totalUnitCount = Int64(allVideoSeries.count)
        progress?.completedUnitCount = 0
        if progress != nil { sendDidUpdateProgressNotification() }

        for videoSerie in allVideoSeries {
            let relationsForVideoSerie = relations.filter({ $0.videoSerieID == videoSerie.id })
            StorageService.shared.write { realm in
                let videos = Array(videoSerie.videos)
                videoSerie.videos.removeAll()
                realm.delete(videos)

                for relation in relationsForVideoSerie {
                    guard let video = StorageService.shared.youtubeVideoWithID(relation.youtubeVideoID, realm: realm) else {
                        print("could not find related video \(relation.youtubeVideoID)")
                        continue
                    }
                    guard let relationID = relation.id else { continue }
                    let existingObject = realm.object(ofType: VideoSerieVideo.self,
                                                      forPrimaryKey: relationID)
                    if existingObject != nil {
                        print("relation exist!!!")
                    }
                    let videoSerieVideo = existingObject ?? VideoSerieVideo()

                    if existingObject == nil {
                        videoSerieVideo.id = relationID
                    }
                    videoSerieVideo.youtubeVideo = video
                    videoSerieVideo.videoDescription = relation.description
                    videoSerie.videos.append(videoSerieVideo)
                }
            }

            progress?.completedUnitCount += 1
            if progress != nil { sendDidUpdateProgressNotification() }
        }

        StorageService.shared.updateVideoSeriesPublishDates()
    }

}
// swiftlint:enable type_body_length file_length
