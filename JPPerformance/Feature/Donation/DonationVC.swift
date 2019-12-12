//
//  DonationVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 12.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class DonationVC: UIViewController {

    @IBOutlet var labelTextTop: UILabel!
    @IBOutlet var labelTextBottom: UILabel!

    @IBOutlet var stackViewTip1: UIStackView!
    @IBOutlet var labelTitleTip1: UILabel!
    @IBOutlet var buttonTip1: UIButton!

    @IBOutlet var stackViewTip2: UIStackView!
    @IBOutlet var labelTitleTip2: UILabel!
    @IBOutlet var buttonTip2: UIButton!

    @IBOutlet var stackViewTip3: UIStackView!
    @IBOutlet var labelTitleTip3: UILabel!
    @IBOutlet var buttonTip3: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "donation_title".localized()
        labelTextTop.text = "donation_text_top".localized()
        labelTextBottom.text = "donation_text_bottom".localized()

        updateInAppPurchases()

        _ = NotificationCenter.default.addObserver(forName: InAppPurchase.didUpdatePurchasesNotification,
                                               object: nil,
                                               queue: .main)
        { [weak self] _ in
            self?.updateInAppPurchases()
        }

        _ = NotificationCenter.default.addObserver(forName: InAppPurchase.didPurchasedNotification,
                                               object: nil,
                                               queue: .main)
        { [weak self] _ in
            let alertController = UIAlertController(title: "donation_thank_you_alert_title".localized(),
                                                    message: "donation_thank_you_alert_text".localized(),
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "donation_thank_you_alert_close_title".localized(),
                                                    style: .default,
                                                    handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }
    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func updateInAppPurchases() {
        stackViewTip1.isHidden = InAppPurchase.shared.tipSmall == nil
        labelTitleTip1.text = InAppPurchase.shared.tipSmall?.localizedTitle
        buttonTip1.setTitle(InAppPurchase.shared.tipSmall?.localizedPrice, for: .normal)

        stackViewTip2.isHidden = InAppPurchase.shared.tipMedium == nil
        labelTitleTip2.text = InAppPurchase.shared.tipMedium?.localizedTitle
        buttonTip2.setTitle(InAppPurchase.shared.tipMedium?.localizedPrice, for: .normal)

        stackViewTip3.isHidden = InAppPurchase.shared.tipMassive == nil
        labelTitleTip3.text = InAppPurchase.shared.tipMassive?.localizedTitle
        buttonTip3.setTitle(InAppPurchase.shared.tipMassive?.localizedPrice, for: .normal)
    }

    @IBAction func actionDonationTouchUpInside(_ sender: UIButton) {
        switch sender {
        case buttonTip1: InAppPurchase.shared.purchase(product: InAppPurchase.shared.tipSmall)
        case buttonTip2: InAppPurchase.shared.purchase(product: InAppPurchase.shared.tipMedium)
        case buttonTip3: InAppPurchase.shared.purchase(product: InAppPurchase.shared.tipMassive)
        default: break
        }
    }

}
