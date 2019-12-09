//
//  TimingLabel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 09.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class TimingLabel: UILabel {

    var backgroundPadding: CGFloat = 10 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        guard let text = text else { return .zero }
        // calculate text size
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font as Any
        ]
        var textSize = (text as NSString).size(withAttributes: attributes)
        textSize.height += backgroundPadding * 2
        textSize.width += backgroundPadding * 2

        return textSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.size.height / 2.0
        layer.borderColor = textColor.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 2.0
    }

}
