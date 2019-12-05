//
//  CarBoardTableViewCellPSNM.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 13.07.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


class CarBoardTableViewCellPSNM: CarTableViewCell {

    @IBOutlet weak var labelKPI: TagLabel!

    override var carItem: JPCarItem? {
        didSet {
            updateKPI()

            guard let carItem = carItem else {
                labelModel.text = ""
                return
            }
            labelModel.text = "\(carItem.manufacturer) \(carItem.model)"
        }
    }

    var isPS: Bool = false {
        didSet {
            updateKPI()
        }
    }

    var isNM: Bool = false {
        didSet {
            updateKPI()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        labelKPI.layoutSubviews()
    }

    private func updateKPI() {
        guard let carItem = carItem else {
            labelDescription.text = ""
            return
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 3
        numberFormatter.maximumFractionDigits = 3

        if isPS, let bestStagePS = carItem.bestStageInPS() {
            labelDescription.text = bestStagePS.title
            labelKPI.text = bestStagePS.displayStringForPS()
        }

        if isNM, let bestStageNM = carItem.bestStageInNM() {
            labelDescription.text = bestStageNM.title
            labelKPI.text = bestStageNM.displayStringForNM()
        }

    }

}
