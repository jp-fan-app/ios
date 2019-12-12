//
//  InAppPurchaseButton.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 12.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class InAppPurchaseButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.size.height / 2.0
        layer.borderColor = tintColor.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 2.0
    }

}
