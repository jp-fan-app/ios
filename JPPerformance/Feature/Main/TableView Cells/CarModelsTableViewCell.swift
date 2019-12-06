//
//  CarModelsTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class CarModelsTableViewCell: UITableViewCell {

    var carModels: [JPFanAppClient.CarModel] = [] {
        didSet {
            collectionView.reloadData()

            lcCollectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        }
    }

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var lcCollectionViewHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

// MARK: - UICollectionViewDataSource

extension CarModelsTableViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carModels.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarModelCollectionViewCell",
                                                      for: indexPath) as! CarModelCollectionViewCell
        // swiftlint:enable force_cast
        cell.carModel = carModels[indexPath.row]
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension CarModelsTableViewCell: UICollectionViewDelegate { }

// MARK: - UICollectionViewDelegateFlowLayout

extension CarModelsTableViewCell: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = self.collectionView(collectionView,
                                        layout: collectionViewLayout,
                                        insetForSectionAt: indexPath.section)
        let itemWidth = collectionView.frame.size.width - (inset.left + inset.right)
        let itemHeight = itemWidth * 1.2
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
