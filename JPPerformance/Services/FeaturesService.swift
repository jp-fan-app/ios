//
//  FeaturesService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.01.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation


class FeaturesService {
    
    static let sharedInstance = FeaturesService()
    private weak var rootViewController: UIViewController?
    private let harpyService = HarpyService()
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let rootViewController = appDelegate.window?.rootViewController else { return }
        
        updateRootViewController(rootViewController)
        harpyService.delegate = self
        
        harpyService.prepare()
    }

    func updateRootViewController(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        harpyService.presentingViewController = rootViewController
        harpyService.prepare()
    }

    func checkForUpdates() {
        harpyService.checkVersion()
    }

    func checkForUpdatesIfNeeded() {
        harpyService.checkVersionDaily()
    }
    
}


extension FeaturesService: HarpyServiceDelegate {
    
    func harpyServiceDid(_ event: String!) {

        switch event {
        case "showUpdateDialog":    AnalyticsService.sharedInstance.fire(event: .updateCheckShowUpdateDialog)
        case "cancel":              AnalyticsService.sharedInstance.fire(event: .updateCheckCancel)
        case "skipVersion":         AnalyticsService.sharedInstance.fire(event: .updateCheckSkipVersion)
        case "launchAppStore":      AnalyticsService.sharedInstance.fire(event: .updateCheckLaunchAppStore)
        default:                    break
        }
    }

}
