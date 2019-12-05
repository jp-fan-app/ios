//
//  StorageService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 19.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


//import Foundation
//import Realm
//import RealmSwift
//
//
//public class StorageService {
//
//    public static let shared = StorageService()
//
//    private init() {
//        print("start realm at: \(String(describing: realm().configuration.fileURL))")
//    }
//
//    private func realm() -> Realm {
//        let config = Realm.Configuration(
//            schemaVersion: 3,
//            migrationBlock:
//        { _, _ in })
//        // swiftlint:disable force_try
//        return try! Realm(configuration: config)
//        // swiftlint:enable force_try
//    }
//
//    public func write(closure: (Realm) -> Void) {
//        write(realm: realm(), closure: closure)
//    }
//
//    private func write(realm: Realm, closure: (Realm) -> Void) {
//        // swiftlint:disable force_try
//        try! realm.write {
//            closure(realm)
//        }
//        // swiftlint:enable force_try
//    }
//
//    public func clearAll() {
//        write { realm in
//            realm.deleteAll()
//        }
//    }
//
//    // MARK: - Manufacturers
//
//    public func manufacturerWithID(_ id: Int, realm: Realm? = nil) -> ManufacturerModel? {
//        let realm = realm ?? self.realm()
//        return realm.object(ofType: ManufacturerModel.self,
//                            forPrimaryKey: id)
//    }
//
//    public func deleteManufacturersExceptIDs(_ ids: [Int]) {
//        let realm = self.realm()
//        let expiredObjects = realm.objects(ManufacturerModel.self).filter("NOT id IN %@", ids)
//        write(realm: realm) { realm in
//            realm.delete(expiredObjects)
//        }
//    }
//
//    // MARK: - Car Models
//
//    public func allCarModels() -> [CarModel] {
//        return Array(realm().objects(CarModel.self))
//    }
//
//    public func carModelWithID(_ id: Int, realm: Realm? = nil) -> CarModel? {
//        let realm = realm ?? self.realm()
//        return realm.object(ofType: CarModel.self,
//                            forPrimaryKey: id)
//    }
//
//    public func deleteCarModelsExceptIDs(_ ids: [Int]) {
//        let realm = self.realm()
//        let expiredObjects = realm.objects(CarModel.self).filter("NOT id IN %@", ids)
//        write(realm: realm) { realm in
//            realm.delete(expiredObjects)
//        }
//    }
//
//    // MARK: - Car Images
//
//    public func carImageWithID(_ id: Int, realm: Realm? = nil) -> CarImage? {
//        let realm = realm ?? self.realm()
//        return realm.object(ofType: CarImage.self,
//                            forPrimaryKey: id)
//    }
//
//    public func deleteCarImagesExceptIDs(_ ids: [Int]) {
//        let realm = self.realm()
//        let expiredObjects = realm.objects(CarImage.self).filter("NOT id IN %@", ids)
//        write(realm: realm) { realm in
//            realm.delete(expiredObjects)
//        }
//    }
//
//    public func carImagesForCarModel(_ carModel: CarModel) -> [CarImage] {
//        let realm = self.realm()
//        return Array(realm.objects(CarImage.self).filter(NSPredicate(format: "carModel == %@", carModel)))
//    }
//
//    // MARK: - Car Stages
//
//    public func allCarStages() -> [CarStage] {
//        return Array(realm().objects(CarStage.self))
//    }
//
//    public func carStagesForCarModel(_ carModel: CarModel) -> [CarStage] {
//        let realm = self.realm()
//        return Array(realm.objects(CarStage.self).filter(NSPredicate(format: "carModel == %@", carModel)))
//    }
//
//    public func carStageWithID(_ id: Int, realm: Realm? = nil) -> CarStage? {
//        let realm = realm ?? self.realm()
//        return realm.object(ofType: CarStage.self,
//                            forPrimaryKey: id)
//    }
//
//    public func deleteCarStagesExceptIDs(_ ids: [Int]) {
//        let realm = self.realm()
//        let expiredObjects = realm.objects(CarStage.self).filter("NOT id IN %@", ids)
//        write(realm: realm) { realm in
//            realm.delete(expiredObjects)
//        }
//    }
//
//    // MARK: - Stage Timings
//
//    public func stageTimingsForCarStage(_ carStage: CarStage) -> [StageTiming] {
//        let realm = self.realm()
//        return Array(realm.objects(StageTiming.self).filter(NSPredicate(format: "carStage == %@", carStage)))
//    }
//
//    public func stageTimingWithID(_ id: Int, realm: Realm? = nil) -> StageTiming? {
//        let realm = realm ?? self.realm()
//        return realm.object(ofType: StageTiming.self,
//                            forPrimaryKey: id)
//    }
//
//    public func deleteStageTimingExceptIDs(_ ids: [Int]) {
//        let realm = self.realm()
//        let expiredObjects = realm.objects(StageTiming.self).filter("NOT id IN %@", ids)
//        write(realm: realm) { realm in
//            realm.delete(expiredObjects)
//        }
//    }
//
//    // MARK: - Videos
//
//    public func allYoutubeVideos() -> [YoutubeVideoModel] {
//        return Array(realm().objects(YoutubeVideoModel.self).sorted(byKeyPath: "publishedAt", ascending: false))
//    }
//
//    public func youtubeVideoWithID(_ id: Int, realm: Realm? = nil) -> YoutubeVideoModel? {
//        let realm = realm ?? self.realm()
//        return realm.object(ofType: YoutubeVideoModel.self,
//                            forPrimaryKey: id)
//    }
//
//    public func youtubeVideoWithVideoID(_ videoId: String, realm: Realm? = nil) -> YoutubeVideoModel? {
//        let realm = self.realm()
//        return realm.objects(YoutubeVideoModel.self).filter(NSPredicate(format: "videoID == %@", videoId)).first
//    }
//
//    public func deleteYoutubeVideosExceptIDs(_ ids: [Int]) {
//        let realm = self.realm()
//        let expiredObjects = realm.objects(YoutubeVideoModel.self).filter("NOT id IN %@", ids)
//        write(realm: realm) { realm in
//            realm.delete(expiredObjects)
//        }
//    }
//
//    // MARK: - Video Series
//
//    public func allVideoSeries() -> [VideoSerie] {
//        return Array(
//            realm()
//                .objects(VideoSerie.self)
//                .filter("isPublic == true")
//                .sorted(byKeyPath: "newestVideoPublishedAt", ascending: false)
//        )
//    }
//
//    public func videoSerieWithID(_ id: Int, realm: Realm? = nil) -> VideoSerie? {
//        let realm = realm ?? self.realm()
//        return realm.object(ofType: VideoSerie.self, forPrimaryKey: id)
//    }
//
//    public func deleteVideoSeriesExceptIDs(_ ids: [Int]) {
//        let realm = self.realm()
//        let expiredObjects = realm.objects(VideoSerie.self).filter("NOT id IN %@", ids)
//        write(realm: realm) { realm in
//            realm.delete(expiredObjects)
//        }
//    }
//
//    public func updateVideoSeriesPublishDates() {
//        for videoSerie in allVideoSeries() {
//            write { _ in
//                videoSerie.newestVideoPublishedAt = videoSerie.newestVideo()?.youtubeVideo?.publishedAt
//            }
//        }
//    }
//
//}
