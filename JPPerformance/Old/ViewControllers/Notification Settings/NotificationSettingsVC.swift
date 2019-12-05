//
//  NotificationSettingsVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 04.09.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


class NotificationSettingsVC: UIViewController {

    @IBOutlet var labelNotificationNewVideosDescription: UILabel!
    @IBOutlet var labelNotificationNewVideosTitle: UILabel!
    @IBOutlet var switchNotificationNewVideos: UISwitch!

    @IBOutlet var labelNotificationCarUpdatesDescription: UILabel!
    @IBOutlet var labelNotificationCarUpdatesTitle: UILabel!
    @IBOutlet var switchNotificationCarUpdates: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "notification_settings_title".localized()

        labelNotificationNewVideosTitle.text = "notification_settings_new_videos_title".localized()
        labelNotificationNewVideosDescription.text = "notification_settings_new_videos_description".localized()
        labelNotificationCarUpdatesTitle.text = "notification_settings_car_updates_title".localized()
        labelNotificationCarUpdatesDescription.text = "notification_settings_car_updates_description".localized()

        updateNotificationState()
    }

    private func updateNotificationState() {
        switchNotificationNewVideos.isOn = Preferences.pushNotificiationsForNewVideosEnabled
        switchNotificationCarUpdates.isOn = Preferences.pushNotificiationsForCarUpdatesEnabled
    }

    @IBAction func actionNotificationNewVideosValueChanged(_ sender: UISwitch) {
        Preferences.pushNotificiationsForNewVideosEnabled = sender.isOn
        registerIfNeeded(wantsOn: sender.isOn,
                         completion:
        { granted in
            if !granted {
                sender.isOn = false
                Preferences.pushNotificiationsForNewVideosEnabled = false
                self.showEnableAlert()
            }
        }, notNeeded: {
            NotificationService.shared.updateSettings()
        })
    }

    @IBAction func actionNotificationCarUpdatesValueChanged(_ sender: UISwitch) {
        Preferences.pushNotificiationsForCarUpdatesEnabled = sender.isOn
        registerIfNeeded(wantsOn: sender.isOn,
                         completion:
        { granted in
            if !granted {
                sender.isOn = false
                Preferences.pushNotificiationsForCarUpdatesEnabled = false
                self.showEnableAlert()
            }
        }, notNeeded: {
            NotificationService.shared.updateSettings()
        })
    }

    private func registerIfNeeded(wantsOn: Bool,
                                  completion: @escaping (_ granted: Bool) -> Void,
                                  notNeeded: @escaping () -> Void) {
        guard wantsOn else {
            notNeeded()
            return
        }
        NotificationService.shared.registerForPushNotifications { granted in
            completion(granted)
        }
    }

    private func showEnableAlert() {
        let alertController = UIAlertController(title: "notification_settings_enable_alert_title".localized(),
                                                message: "notification_settings_enable_alert_text".localized(),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "notification_settings_enable_alert_settings_button".localized(), style: .default, handler: { (action) in

            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                      options: [:],
                                      completionHandler: nil)
        }))
        alertController.addAction(UIAlertAction(title: "notification_settings_enable_alert_cancel_button".localized(), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}
