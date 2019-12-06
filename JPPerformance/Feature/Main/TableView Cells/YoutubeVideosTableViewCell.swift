//
//  YoutubeVideosTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


class YoutubeVideosTableViewCell: UITableViewCell {

    var youtubeVideos: [JPFanAppClient.YoutubeVideo] = [] {
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

extension YoutubeVideosTableViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return youtubeVideos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YoutubeVideoCollectionViewCell",
                                                      for: indexPath) as! YoutubeVideoCollectionViewCell
        // swiftlint:enable force_cast
        cell.youtubeVideo = youtubeVideos[indexPath.row]
        return cell
    }

}
