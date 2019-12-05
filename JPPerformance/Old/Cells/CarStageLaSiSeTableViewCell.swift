//
//  CarStageLaSiSeTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 18.05.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class CarStageLaSiSeTableViewCell: CarTableViewCell {

    @IBOutlet weak var labelSeconds: TagLabel!

    override var carItem: JPCarItem? {
        didSet {
            guard let carItem = carItem else {
                labelModel.text = ""
                return
            }
            labelModel.text = "\(carItem.manufacturer) \(carItem.model)"
            labelSeconds.text = carItem.bestStageInLaSiSe()?.displayStringForLaSiSe()
        }
    }

}
