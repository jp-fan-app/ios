//
//  VideoSeriesListVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient

class VideoSeriesListVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!

    private let http = UIApplication.http
    var videoSeries: [JPFanAppClient.VideoSerie] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "video-series".localized()

        reloadVideoSeries()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideoSerieDetail",
            let videoSerieDetailVC = segue.destination as? VideoSerieDetailVC,
            let videoSerie = sender as? JPFanAppClient.VideoSerie
        {
            videoSerieDetailVC.videoSerie = videoSerie
        }
    }

    private func reloadVideoSeries() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.http.getVideoSeries().whenSuccess { index in
                self.videoSeries = index.sorted(by: { $0.updatedAt ?? Date() > $1.updatedAt ?? Date() })
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }

}

// MARK: - UICollectionViewDataSource

extension VideoSeriesListVC: UICollectionViewDataSource {

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

// MARK: - UICollectionViewDelegate

extension VideoSeriesListVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showVideoSerieDetail",
                     sender: videoSeries[indexPath.row])
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension VideoSeriesListVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = self.collectionView(collectionView,
                                        layout: collectionViewLayout,
                                        insetForSectionAt: indexPath.section)
        let interitemSpacing = self.collectionView(collectionView,
                                                   layout: collectionViewLayout,
                                                   minimumInteritemSpacingForSectionAt: indexPath.section)
        let numberOfItemsPerRow = 2
        let interitemWidth = CGFloat(numberOfItemsPerRow - 1) * interitemSpacing
        let totalWidth = collectionView.frame.size.width - (inset.left + inset.right) - interitemWidth
        let itemWidth = CGFloat(totalWidth / CGFloat(numberOfItemsPerRow))

        return CGSize(width: itemWidth, height: itemWidth * 0.6)
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
