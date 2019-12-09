//
//  YoutubeVideosTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient


protocol YoutubeVideosTableViewCellDelegate: class {

    func youtubeVideosTableViewCell(_ youtubeVideosTableViewCell: YoutubeVideosTableViewCell,
                                    didSelect youtubeVideo: JPFanAppClient.YoutubeVideo)

}


class YoutubeVideosTableViewCell: UITableViewCell {

    var youtubeVideos: [JPFanAppClient.YoutubeVideo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    weak var delegate: YoutubeVideosTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

// MARK: - UICollectionViewDataSource

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

extension YoutubeVideosTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.youtubeVideosTableViewCell(self, didSelect: youtubeVideos[indexPath.row])
    }

}
