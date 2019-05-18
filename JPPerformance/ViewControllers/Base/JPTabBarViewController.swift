//
//  TabBarViewController.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit


class JPTabBarViewController: UITabBarController {

    static var isTabBarControllerLoaded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.items?[0].title = "cars".localized()
        tabBar.items?[0].accessibilityLabel = "cars"

        tabBar.items?[1].title = "board".localized()
        tabBar.items?[1].accessibilityLabel = "board"

        tabBar.items?[2].title = "youtube".localized()
        tabBar.items?[2].accessibilityLabel = "youtube"

        tabBar.items?[3].title = "series".localized()
        tabBar.items?[3].accessibilityLabel = "series"

        tabBar.items?[4].title = "Info"
        tabBar.items?[4].accessibilityLabel = "info"

        FeaturesService.sharedInstance.updateRootViewController(self)
        FeaturesService.sharedInstance.checkForUpdates()

        _ = NotificationCenter.default.addObserver(forName: PurchaseService.didPurchasedNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main)
        { _ in
            self.showPurchaseThankYouAlert()
        }

        JPTabBarViewController.isTabBarControllerLoaded = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let selectedViewController = selectedViewController else {
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        
        return selectedViewController.supportedInterfaceOrientations
    }

    override var shouldAutorotate: Bool {
        guard let selectedViewController = selectedViewController else {
            return true
        }
        
        return selectedViewController.shouldAutorotate
    }

    private func showPurchaseThankYouAlert() {
        let alertController = UIAlertController(title: "donation_thank_you_alert_title".localized(),
                                                message: "donation_thank_you_alert_text".localized(),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "donation_thank_you_alert_close_title".localized(),
                                                style: .default,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}
