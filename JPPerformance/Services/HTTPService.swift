//
//  HTTPService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 19.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import JPFanAppClient


public class HTTPService {

    public static let shared = HTTPService()

    let client: JPFanAppClient

    private init() {
        client = JPFanAppClient.production(accessToken: Keys.jpAPIKey())
    }

    public func manufacturers(completion: @escaping ([JPFanAppClient.ManufacturerModel]?) -> Void) {
        client.manufacturersIndex { result in
            switch result {
            case .success(let manufacturers):
                completion(manufacturers)
            case .failure:
                completion(nil)
            }
        }
    }

    public func manufacturerShow(id: Int, completion: @escaping (JPFanAppClient.ManufacturerModel?) -> Void) {
        client.manufacturersShow(id: id) { result in
            switch result {
            case .success(let manufacturer):
                completion(manufacturer)
            case .failure:
                completion(nil)
            }
        }
    }

    public func carModels(completion: @escaping ([JPFanAppClient.CarModel]?) -> Void) {
        client.modelsIndex { result in
            switch result {
            case .success(let models):
                completion(models)
            case .failure:
                completion(nil)
            }
        }
    }

    public func carModelShow(id: Int, completion: @escaping (JPFanAppClient.CarModel?) -> Void) {
        client.modelsShow(id: id) { result in
            switch result {
            case .success(let carModel):
                completion(carModel)
            case .failure:
                completion(nil)
            }
        }
    }

    public func carModelImages(id: Int,
                               completion: @escaping ([JPFanAppClient.CarImage]?) -> Void) {
        client.modelsImages(id: id) { result in
            switch result {
            case .success(let carImages):
                completion(carImages)
            case .failure:
                completion(nil)
            }
        }
    }

    public func carModelStages(id: Int,
                               completion: @escaping ([JPFanAppClient.CarStage]?) -> Void) {
        client.modelsStages(id: id) { result in
            switch result {
            case .success(let carStages):
                completion(carStages)
            case .failure:
                completion(nil)
            }
        }
    }

    public func carImages(completion: @escaping ([JPFanAppClient.CarImage]?) -> Void) {
        client.imagesIndex { result in
            switch result {
            case .success(let carImages):
                completion(carImages)
            case .failure:
                completion(nil)
            }
        }
    }

    public func carImageFile(id: Int,
                             completion: @escaping (_ id: Int, UIImage?) -> Void) {
        client.imagesFile(id: id) { result in
            switch result {
            case .success(let file):
                guard let data = file.data else {
                    completion(id, nil)
                    return
                }
                completion(id, UIImage(data: data))
            case .failure:
                completion(id, nil)
            }
        }
    }

    public func carStages(completion: @escaping ([JPFanAppClient.CarStage]?) -> Void) {
        client.stagesIndex { result in
            switch result {
            case .success(let carStages):
                completion(carStages)
            case .failure:
                completion(nil)
            }
        }
    }

    public func videosForCarStage(carStageID: Int,
                                  completion: @escaping ([JPFanAppClient.YoutubeVideo]?) -> Void) {
        client.stagesVideos(id: carStageID) { result in
            switch result {
            case .success(let videos):
                completion(videos)
            case .failure:
                completion(nil)
            }
        }
    }

    public func timings(completion: @escaping ([JPFanAppClient.StageTiming]?) -> Void) {
        client.timingsIndex { result in
            switch result {
            case .success(let timings):
                completion(timings)
            case .failure:
                completion(nil)
            }
        }
    }

    public func videos(completion: @escaping ([JPFanAppClient.YoutubeVideo]?) -> Void) {
        client.videosIndex { result in
            switch result {
            case .success(let videos):
                completion(videos)
            case .failure:
                completion(nil)
            }
        }
    }

    public func videoShow(id: Int, completion: @escaping (JPFanAppClient.YoutubeVideo?) -> Void) {
        client.videosShow(id: id) { result in
            switch result {
            case .success(let video):
                completion(video)
            case .failure:
                completion(nil)
            }
        }
    }

    public func stagesVideosRelations(completion: @escaping ([JPFanAppClient.CarStageYoutubeVideoRelation]?) -> Void) {
        client.stagesVideosRelations { result in
            switch result {
            case .success(let relations):
                completion(relations)
            case .failure:
                completion(nil)
            }
        }
    }

    public func devicesCreate(pushToken: String, completion: @escaping (Bool) -> Void) {
        guard let languageCode = Locale.current.languageCode else {
            completion(false)
            return
        }
        let device = JPFanAppClient.Device(languageCode: languageCode,
                                           pushToken: pushToken,
                                           platform: .ios)
        client.devicesCreate(device: device) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    public func deviceIsRegistered(pushToken: String, completion: @escaping (Bool) -> Void) {
        client.devicesShow(pushToken: pushToken) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    public func devicesPing(pushToken: String, completion: @escaping () -> Void) {
        client.devicesPing(pushToken: pushToken) { _ in
            completion()
        }
    }

    public func devicesNotificationPreferences(pushToken: String,
                                               completion: @escaping ([JPFanAppClient.NotificationPreference]?) -> Void) {
        client.devicesNotificationPreferences(pushToken: pushToken) { result in
            switch result {
            case .success(let preferences):
                completion(preferences)
            case .failure:
                completion(nil)
            }
        }
    }

    public func devicesNotificationPreferencesCreate(pushToken: String,
                                                     entityType: String,
                                                     entityID: String? = nil,
                                                     completion: @escaping (Bool) -> Void) {
        let preference = JPFanAppClient.NotificationPreference(entityType: entityType, entityID: entityID)
        client.devicesNotificationPreferencesCreate(pushToken: pushToken,
                                                    notificationPreference: preference)
        { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    public func devicesNotificationPreferencesDelete(pushToken: String,
                                                     id: Int,
                                                     completion: @escaping (Bool) -> Void) {
        client.devicesNotificationPreferencesDelete(pushToken: pushToken, id: id) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    public func notificationsTrack(id: String) {
        client.notificationsTrack(id: id) { result in
            switch result {
            case .success:
                print("track success")
            case .failure:
                print("track failure")
            }
        }
    }

    public func videoSeries(completion: @escaping ([JPFanAppClient.VideoSerie]?) -> Void) {
        client.videoSeriesIndex { result in
            switch result {
            case .success(let videoSeries):
                completion(videoSeries)
            case .failure:
                completion(nil)
            }
        }
    }

    public func videoSeriesVideosRelations(completion: @escaping ([JPFanAppClient.VideoSerieYoutubeVideoRelation]?) -> Void) {
        client.videoSeriesVideosRelations { result in
            switch result {
            case .success(let relations):
                completion(relations)
            case .failure:
                completion(nil)
            }
        }
    }

}
