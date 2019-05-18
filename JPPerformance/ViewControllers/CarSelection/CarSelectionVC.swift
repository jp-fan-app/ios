//
//  CarSelectionVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 27.06.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


protocol CarSelectionVCDelegate: class {

    func carSelectionVC(_ carSelectionVC: CarSelectionVC, didSelectCarItem carItem: JPCarItem)

}

class CarSelectionVC: JPCarsVC {

    weak var delegate: CarSelectionVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "car_selection".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title
    }

    override func didSelectCarItem(_ carItem: JPCarItem) {
        delegate?.carSelectionVC(self, didSelectCarItem: carItem)
        navigationController?.popViewController(animated: true)
    }

}
