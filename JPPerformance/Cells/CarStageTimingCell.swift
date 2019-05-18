//
//  CarStageTimingCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 23.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//

import UIKit


class CarStageTimingCell: UITableViewCell {

    @IBOutlet weak var labelRange: UILabel!
    @IBOutlet weak var stackViewTimings: UIStackView!

    var carStageTiming: JPCarStageTiming? {
        didSet {
            guard let carStageTiming = carStageTiming else {
                labelRange.text = ""

                for subView in stackViewTimings.subviews {
                    subView.removeFromSuperview()
                }

                return
            }


            labelRange.text = carStageTiming.range

            for subView in stackViewTimings.subviews {
                subView.removeFromSuperview()
            }

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 3
            numberFormatter.maximumFractionDigits = 3

            let bestSecond = carStageTiming.bestSecond()

            // add seconds label
            for seconds in carStageTiming.seconds {
                let secondsWrapperView = UIView()
                secondsWrapperView.translatesAutoresizingMaskIntoConstraints = false
                secondsWrapperView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)

                let secondsLabel = TagLabel()
                secondsLabel.translatesAutoresizingMaskIntoConstraints = false
                secondsLabel.text = numberFormatter.string(from: NSNumber(value: seconds))
                secondsLabel.font = UIFont(name: "Menlo", size: 12)
                secondsLabel.textAlignment = .center
                secondsLabel.textColor = UIColor.jpDarkGrayColor
                secondsLabel.backgroundColor = UIColor.clear
                secondsLabel.tagBackgroundColor = UIColor.jpDarkGrayColor.withAlphaComponent(0.15)
                if seconds == bestSecond && carStageTiming.seconds.count > 1 {
                    secondsLabel.tagBackgroundColor = UIColor.green.withAlphaComponent(0.5)
                }
                secondsLabel.layer.cornerRadius = 2
                secondsLabel.layer.masksToBounds = true
                secondsWrapperView.addSubview(secondsLabel)
                secondsWrapperView.addConstraints([
                    secondsLabel.leftAnchor.constraint(equalTo: secondsWrapperView.leftAnchor),
                    secondsLabel.topAnchor.constraint(equalTo: secondsWrapperView.topAnchor),
                    secondsLabel.rightAnchor.constraint(equalTo: secondsWrapperView.rightAnchor),
                    secondsLabel.bottomAnchor.constraint(equalTo: secondsWrapperView.bottomAnchor)
                ])

                stackViewTimings.addArrangedSubview(secondsWrapperView)
            }

            let stretchingView = UIView()
            stretchingView.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
            stretchingView.backgroundColor = UIColor.clear
            stretchingView.translatesAutoresizingMaskIntoConstraints = false
            stackViewTimings.addArrangedSubview(stretchingView)

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.clear
    }

}
