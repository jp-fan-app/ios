//
//  ManufacturersTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


protocol ManufacturersTableViewCellDelegate: class {

    func manufacturersTableViewCell(_ manufacturersTableViewCell: ManufacturersTableViewCell,
                                    didSelect manufacturer: JPFanAppClient.ManufacturerModel)

}


class ManufacturersTableViewCell: UITableViewCell {

    var manufacturers: [JPFanAppClient.ManufacturerModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var selectedManufacturer: JPFanAppClient.ManufacturerModel? {
        didSet {
            updateCollectionViewSelection()
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    weak var delegate: ManufacturersTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func updateCollectionViewSelection() {
        guard let selectedId = selectedManufacturer?.id else { return }
        guard let index = manufacturers.firstIndex(where: { $0.id == selectedId }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }

}

// MARK: - UICollectionViewDataSource

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

// MARK: - UICollectionViewDelegate

extension ManufacturersTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.manufacturersTableViewCell(self, didSelect: manufacturers[indexPath.row])
    }

}
