//
//  CarBoardTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//

import UIKit


class CarBoardTableViewCell: CarTableViewCell {

    @IBOutlet weak var labelTiming: TagLabel!

    override var carItem: JPCarItem? {
        didSet {
            updateRange()

            guard let carItem = carItem else {
                labelModel.text = ""
                return
            }
            labelModel.text = "\(carItem.manufacturer) \(carItem.model)"
        }
    }

    var range: String? {
        didSet {
            updateRange()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        labelTiming.layoutSubviews()
    }

    private func updateRange() {
        guard let carItem = carItem,
            let range = range,
            let bestStage = carItem.bestStage(inRange: range)
        else {
            labelDescription.text = ""
            return
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 3
        numberFormatter.maximumFractionDigits = 3

        labelDescription.text = bestStage.title
        let number = NSNumber(value: bestStage.bestTiming(inRange: range)?.bestSecond() ?? 0)
        labelTiming.text = numberFormatter.string(from: number)
    }

}
