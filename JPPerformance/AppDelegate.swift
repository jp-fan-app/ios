//
//  AppDelegate.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import Firebase
//import CoreSpotlight


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let http = HTTP()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Firebase
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        FirebaseApp.configure()

        // AdMob
        AdMob.start()

        // Review
        Review.increaseAppStartCount()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            Review.requestReviewIfNeeded()
        }

//        http.getManufacturers().whenSuccess { index in
//            print("manufacturers: \(index.count)")
//        }
//
//        http.getCarModels().whenSuccess { index in
//            print("models: \(index.count)")
//        }

//        http.getCarImages().whenSuccess { index in
//            print("car images: \(index.count)")
//        }

//        http.getCarStages().whenSuccess { index in
//            print("stages: \(index.count)")
//        }

//        http.getStageTimings().whenSuccess { index in
//            print("timings: \(index.count)")
//        }

//        http.getYoutubeVideos().whenSuccess { index in
//            print("youtube videos: \(index.count)")
//        }

//        http.getStagesVideos().whenSuccess { index in
//            print("stage videos: \(index.count)")
//        }

//        http.getVideoSeries().whenSuccess { index in
//            print("video series: \(index.count)")
//        }

//        http.getVideoSerieYoutubeVideos().whenSuccess { index in
//            print("video series youtube videos: \(index.count)")
//        }

//        PurchaseService.shared.completeTransactions()
//        PurchaseService.shared.retrieveProductsInfo()
//
//        NotificationService.shared.initialize()
//        NotificationService.shared.sendDevicePing()

        return true
    }

//    func application(_ application: UIApplication,
//                     continue userActivity: NSUserActivity,
//                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//        if userActivity.activityType == CSSearchableItemActionType, let info = userActivity.userInfo, let selectedIdentifier = info[CSSearchableItemActivityIdentifier] as? String {
//
//            if selectedIdentifier.contains("youtube:") {
//                AnalyticsService.sharedInstance.fire(event: .spotlightOpenedYoutubeVideo)
//                let startIndex = selectedIdentifier.index(selectedIdentifier.startIndex, offsetBy: 8)
//                let youtubeID = selectedIdentifier[startIndex...]
//                navigateToYoutubeAndOpenVideo(withIdentifier: String(youtubeID))
//            }
//        }
//
//        return true
//    }
//
//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let tokenParts = deviceToken.map { data -> String in
//            return String(format: "%02.2hhx", data)
//        }
//        let token = tokenParts.joined()
//        NotificationService.shared.updateSettingsWithDeviceToken(token)
//    }
//
//    public func navigateToYoutubeAndOpenVideo(withIdentifier identifier: String) {
//        guard let initial = window?.rootViewController as? JPInitialViewController else { return }
//        initial.tabBarViewController?.selectedIndex = 2
//        guard let navigationController = initial.tabBarViewController?.selectedViewController as? UINavigationController else { return }
//        navigationController.popToRootViewController(animated: false)
//        guard let youtubeVC = navigationController.viewControllers.first as? JPYoutubeVC else { return }
//
//        guard let video = StorageService.shared.youtubeVideoWithVideoID(identifier) else { return }
//        youtubeVC.performSegue(withIdentifier: "showDetail",
//                               sender: video)
//    }
//
//    public func navigateToCarModel(_ carModel: CarModel, reloadData: Bool = false) {
//        guard let initial = window?.rootViewController as? JPInitialViewController else { return }
//        initial.tabBarViewController?.selectedIndex = 0
//        guard let navigationController = initial.tabBarViewController?.selectedViewController as? UINavigationController else { return }
//        navigationController.popToRootViewController(animated: false)
//        guard let carsVC = navigationController.viewControllers.first as? JPCarsVC else { return }
//
//        carsVC.selectCarModel(carModel, reloadData: reloadData)
//    }

}
