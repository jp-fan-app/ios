//
//  CarModelTimingTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class CarModelTimingTableViewCell: UITableViewCell {

    @IBOutlet var labelRange: UILabel!
    @IBOutlet var labelSecond1: UILabel!
    @IBOutlet var labelSecond2: UILabel!
    @IBOutlet var labelSecond3: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        labelRange.dynamicFont(weight: .regular, textStyle: .headline)
        labelSecond1.dynamicFont(weight: .bold, textStyle: .headline)
        labelSecond2.dynamicFont(weight: .bold, textStyle: .headline)
        labelSecond3.dynamicFont(weight: .bold, textStyle: .headline)
    }

}
