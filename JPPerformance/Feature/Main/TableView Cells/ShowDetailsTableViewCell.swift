//
//  ShowDetailsTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class ShowDetailsTableViewCell: UITableViewCell {

    @IBOutlet var buttonAction: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonAction.layer.cornerRadius = 20
        buttonAction.layer.masksToBounds = true
    }

}
