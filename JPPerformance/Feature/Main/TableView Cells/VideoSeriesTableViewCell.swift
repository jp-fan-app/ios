//
//  VideoSeriesTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class VideoSeriesTableViewCell: UITableViewCell {

    var videoSeries: [JPFanAppClient.VideoSerie] = [] {
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

extension VideoSeriesTableViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoSeries.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoSerieCollectionViewCell",
                                                      for: indexPath) as! VideoSerieCollectionViewCell
        // swiftlint:enable force_cast
        cell.videoSerie = videoSeries[indexPath.row]
        return cell
    }

}
