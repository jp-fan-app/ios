//
//  ManufacturersTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class ManufacturersTableViewCell: UITableViewCell {

    var manufacturers: [JPFanAppClient.ManufacturerModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.dataSource = self
    }

}

extension ManufacturersTableViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manufacturers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ManufacturerCollectionViewCell",
                                                      for: indexPath) as! ManufacturerCollectionViewCell
        // swiftlint:enable force_cast
        cell.manufacturer = manufacturers[indexPath.row]
        return cell
    }

}
