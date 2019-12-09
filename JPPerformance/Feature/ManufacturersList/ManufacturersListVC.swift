//
//  ManufacturersListVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class ManufacturersListVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!

    let http = HTTP()
    var manufacturers: [JPFanAppClient.ManufacturerModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "manufacturers".localized()

        reloadManufacturers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func reloadManufacturers() {
       http.getManufacturers().whenSuccess { index in
           self.manufacturers = index.sorted(by: { $0.name < $1.name })
           DispatchQueue.main.async {
               self.collectionView.reloadData()
           }
       }
   }

}

// MARK: - UICollectionViewDataSource

extension ManufacturersListVC: UICollectionViewDataSource {

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

extension ManufacturersListVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showCarModelsSearch", sender: self)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ManufacturersListVC: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = self.collectionView(collectionView,
                                        layout: collectionViewLayout,
                                        insetForSectionAt: indexPath.section)
        let interitemSpacing = self.collectionView(collectionView,
                                                   layout: collectionViewLayout,
                                                   minimumInteritemSpacingForSectionAt: indexPath.section)
        let numberOfItemsPerRow = 3
        let interitemWidth = CGFloat(numberOfItemsPerRow - 1) * interitemSpacing
        let totalWidth = collectionView.frame.size.width - (inset.left + inset.right) - interitemWidth
        let itemWidth = CGFloat(totalWidth / CGFloat(numberOfItemsPerRow))

        return CGSize(width: itemWidth, height: itemWidth)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

}
