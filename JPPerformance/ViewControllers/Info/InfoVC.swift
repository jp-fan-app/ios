//
//  InfoVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 03.09.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


class InfoVC: UIViewController {

    @IBOutlet var buttonNotificationSettings: UIButton!
    @IBOutlet var buttonDonationInformation: UIButton!
    @IBOutlet var buttonSendFeedback: UIButton!

    @IBOutlet var labelDisclaimerTitle: UILabel!
    @IBOutlet var labelDisclaimerText: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        buttonNotificationSettings.setTitle("info_notification_settings_button_title".localized(),
                                            for: .normal)
        buttonNotificationSettings.accessibilityIdentifier = "notifications"
        buttonDonationInformation.setTitle("info_donation_information_button_title".localized(),
                                           for: .normal)
        buttonSendFeedback.setTitle("info_send_feedback_button_title".localized(),
                                    for: .normal)

        labelDisclaimerTitle.text = "info_disclaimer_title".localized()
        labelDisclaimerText.text = "info_disclaimer_text".localized()
    }

    @IBAction func actionSendFeedback(_ sender: UIButton) {
        FeedbackService.sharedInstance.openMailComposerForFeedback(parentViewController: self)
    }

}
