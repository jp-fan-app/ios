//
//  DonationVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 04.09.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


class DonationVC: UIViewController {

    @IBOutlet var labelDonationTextTop: UILabel!
    @IBOutlet var labelDonationTextBottom: UILabel!

    @IBOutlet var viewDonationTipSmall: UIView!
    @IBOutlet var labelDonationTipSmall: UILabel!
    @IBOutlet var buttonDonationTipSmall: UIButton!

    @IBOutlet var viewDonationTipMedium: UIView!
    @IBOutlet var labelDonationTipMedium: UILabel!
    @IBOutlet var buttonDonationTipMedium: UIButton!

    @IBOutlet var viewDonationTipMassive: UIView!
    @IBOutlet var labelDonationTipMassive: UILabel!
    @IBOutlet var buttonDonationTipMassive: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "donation_title".localized()
        labelDonationTextTop.text = "donation_text_top".localized()
        labelDonationTextBottom.text = "donation_text_bottom".localized()
        updateDonationViews()

        _ = NotificationCenter.default.addObserver(forName: PurchaseService.didUpdatePurchasesNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main)
        { [weak self] _ in
            self?.updateDonationViews()
        }

        buttonDonationTipSmall.layer.cornerRadius = 5
        buttonDonationTipSmall.layer.borderColor = UIColor.jpDarkGrayColor.cgColor
        buttonDonationTipSmall.layer.borderWidth = 1

        buttonDonationTipMedium.layer.cornerRadius = 5
        buttonDonationTipMedium.layer.borderColor = UIColor.jpDarkGrayColor.cgColor
        buttonDonationTipMedium.layer.borderWidth = 1

        buttonDonationTipMassive.layer.cornerRadius = 5
        buttonDonationTipMassive.layer.borderColor = UIColor.jpDarkGrayColor.cgColor
        buttonDonationTipMassive.layer.borderWidth = 1
    }

    private func updateDonationViews() {
        viewDonationTipSmall.isHidden = PurchaseService.shared.tipSmall == nil
        labelDonationTipSmall.text = "🙂 \(PurchaseService.shared.tipSmall?.localizedTitle ?? "")"
        buttonDonationTipSmall.setTitle(PurchaseService.shared.tipSmall?.localizedPrice,
                                        for: .normal)

        viewDonationTipMedium.isHidden = PurchaseService.shared.tipMedium == nil
        labelDonationTipMedium.text = "😃 \(PurchaseService.shared.tipMedium?.localizedTitle ?? "")"
        buttonDonationTipMedium.setTitle(PurchaseService.shared.tipMedium?.localizedPrice,
                                         for: .normal)

        viewDonationTipMassive.isHidden = PurchaseService.shared.tipMassive == nil
        labelDonationTipMassive.text = "😍 \(PurchaseService.shared.tipMassive?.localizedTitle ?? "")"
        buttonDonationTipMassive.setTitle(PurchaseService.shared.tipMassive?.localizedPrice,
                                          for: .normal)
    }

    @IBAction func actionButtonTipSmall(_ sender: UIButton) {
        guard let product = PurchaseService.shared.tipSmall else { return }
        PurchaseService.shared.purchase(product: product)
    }

    @IBAction func actionButtonTipMedium(_ sender: UIButton) {
        guard let product = PurchaseService.shared.tipMedium else { return }
        PurchaseService.shared.purchase(product: product)
    }

    @IBAction func actionButtonTipMassive(_ sender: UIButton) {
        guard let product = PurchaseService.shared.tipMassive else { return }
        PurchaseService.shared.purchase(product: product)
    }

}
