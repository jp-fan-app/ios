//
//  FeedbackService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 22.10.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation
import MessageUI


public class Feedback: NSObject {

    func openMailComposerForFeedback(parentViewController: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            openMailWithURL()
            return
        }

        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["apps.christoph@gmail.com"])
        mailComposerVC.setSubject("Feedback JP Performance Fan App")
        parentViewController.present(mailComposerVC, animated: true, completion: nil)
    }

    private func openMailWithURL() {
        guard let url = URL(string: "mailto:apps.christoph@gmail.com&subject=Feedback JP Performance Fan App") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}


extension Feedback: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            Review.requestReviewIfNeeded(userDemonstratedEngagement: true)
        }
    }

}
