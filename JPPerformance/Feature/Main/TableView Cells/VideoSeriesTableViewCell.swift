//
//  VideoSeriesTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


protocol VideoSeriesTableViewCellDelegate: class {

    func videoSeriesTableViewCell(_ videoSeriesTableViewCell: VideoSeriesTableViewCell,
                                  didSelect videoSerie: JPFanAppClient.VideoSerie)

}


class VideoSeriesTableViewCell: UITableViewCell {

    var videoSeries: [JPFanAppClient.VideoSerie] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    weak var delegate: VideoSeriesTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

// MARK: - UICollectionViewDataSource

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


extension VideoSeriesTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.videoSeriesTableViewCell(self, didSelect: videoSeries[indexPath.row])
    }

}
