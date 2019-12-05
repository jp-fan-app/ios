//
//  NotificationService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 15.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


//import Foundation
//import UserNotifications
//
//
//class NotificationService: NSObject {
//
//    static let shared = NotificationService()
//
//    func initialize() {
//        UNUserNotificationCenter.current().delegate = self
//    }
//
//    func registerForPushNotifications(completion: @escaping (_ granted: Bool) -> Void) {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
//        { (granted, _) in
//            print("Permission granted: \(granted)")
//            DispatchQueue.main.async {
//                completion(granted)
//            }
//
//            guard granted else { return }
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
//    }
//
//    func updateSettingsWithDeviceToken(_ deviceToken: String) {
//        Preferences.pushToken = deviceToken
//        updateSettings()
//    }
//
//    func updateSettings() {
//        guard let pushToken = Preferences.pushToken else { return }
//
//        HTTPService.shared.deviceIsRegistered(pushToken: pushToken) { isRegistered in
//            if isRegistered {
//                self.sendSettings()
//            } else {
//                HTTPService.shared.devicesCreate(pushToken: pushToken) { success in
//                    guard success else { return }
//                    self.sendSettings()
//                }
//            }
//        }
//    }
//
//    func sendDevicePing() {
//        guard let pushToken = Preferences.pushToken else { return }
//        HTTPService.shared.devicesPing(pushToken: pushToken) { }
//    }
//
//    private func sendSettings() {
//        guard let pushToken = Preferences.pushToken else { return }
//        print("update settings for \(pushToken)")
//
//        HTTPService.shared.devicesNotificationPreferences(pushToken: pushToken) { preferences in
//            guard let preferences = preferences else { return }
//
//            // Video Updates
//            let wantsVideo = Preferences.pushNotificiationsForNewVideosEnabled
//            let videoSubscription = preferences.first(where: { $0.entityType == "Video" && $0.entityID == nil })
//
//            if wantsVideo && videoSubscription == nil {
//                HTTPService.shared.devicesNotificationPreferencesCreate(pushToken: pushToken,
//                                                                        entityType: "Video",
//                                                                        completion: { _ in })
//            } else if !wantsVideo && videoSubscription != nil {
//                if let videoSubscriptionID = videoSubscription?.id {
//                    HTTPService.shared.devicesNotificationPreferencesDelete(pushToken: pushToken,
//                                                                            id: videoSubscriptionID,
//                                                                            completion: { _ in })
//                }
//            }
//
//            // Car Updates
//            let wantsCarUpdates = Preferences.pushNotificiationsForCarUpdatesEnabled
//            let carUpdateSubscription = preferences.first(where: { $0.entityType == "CarModel" && $0.entityID == nil })
//
//            if wantsCarUpdates && carUpdateSubscription == nil {
//                HTTPService.shared.devicesNotificationPreferencesCreate(pushToken: pushToken,
//                                                                        entityType: "CarModel",
//                                                                        completion: { _ in })
//            } else if !wantsCarUpdates && carUpdateSubscription != nil {
//                if let carUpdateSubscriptionID = carUpdateSubscription?.id {
//                    HTTPService.shared.devicesNotificationPreferencesDelete(pushToken: pushToken,
//                                                                            id: carUpdateSubscriptionID,
//                                                                            completion: { _ in })
//                }
//            }
//        }
//    }
//
//}
//
//
//extension NotificationService: UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let custom = response.notification.request.content.userInfo["custom"] as? [AnyHashable: Any]
//        let customA = custom?["a"] as? [AnyHashable: Any]
//        let entityType = customA?["entityType"] as? String
//        let entityID = customA?["entityID"] as? String
//        let identifier = custom?["i"] as? String
//
//        if let identifier = identifier {
//            HTTPService.shared.notificationsTrack(id: identifier)
//        }
//
//        if entityType == "Video", let entityID = entityID, let videoID = Int(entityID) {
//            if let video = StorageService.shared.youtubeVideoWithID(videoID) {
//                whenTabBarIsLoaded {
//                    UIApplication.appDelegate()?.navigateToYoutubeAndOpenVideo(withIdentifier: video.videoID)
//                }
//            } else {
//                SyncService.shared.synchronizeSingleYoutubeVideo(id: videoID) { videoModel in
//                    if let video = videoModel {
//                        self.whenTabBarIsLoaded {
//                            UIApplication.appDelegate()?.navigateToYoutubeAndOpenVideo(withIdentifier: video.videoID)
//                        }
//                    }
//                }
//            }
//        }
//
//        if entityType == "CarModel", let entityID = entityID, let carModelID = Int(entityID) {
//            if let carModel = StorageService.shared.carModelWithID(carModelID) {
//                whenTabBarIsLoaded {
//                    UIApplication.appDelegate()?.navigateToCarModel(carModel)
//                }
//            } else {
//                SyncService.shared.synchronizeSingleCarModel(id: carModelID,
//                                                             includingRelations: true)
//                { carModel in
//                    if let carModel = carModel {
//                        self.whenTabBarIsLoaded {
//                            UIApplication.appDelegate()?.navigateToCarModel(carModel, reloadData: true)
//                        }
//                    }
//                }
//            }
//        }
//
//        // no 2 day cache... synchronize all in parallel
//        SyncService.shared.synchronize()
//
//        completionHandler()
//    }
//
//    func whenTabBarIsLoaded(_ closure: @escaping () -> Void) {
//        if JPTabBarViewController.isTabBarControllerLoaded {
//            DispatchQueue.main.async {
//                closure()
//            }
//        } else {
//            DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 0.5) {
//                self.whenTabBarIsLoaded(closure)
//            }
//        }
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.badge, .alert])
//    }
//
//}
