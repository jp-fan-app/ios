//
//  NavigationBar.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 27.10.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


class NavigationBar: UINavigationBar {

    let loadingView = UIView()
    var lcLoadingViewWidth: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        _ = NotificationCenter.default.addObserver(forName: SyncService.didUpdateProgressNotification,
                                                   object: nil,
                                                   queue: .main)
        { _ in
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations:
            {
                self.updateFromProgress()
            }, completion: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if loadingView.superview == nil {
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            loadingView.backgroundColor = UIColor.jpDarkGrayColor
            addSubview(loadingView)
            loadingView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            lcLoadingViewWidth = loadingView.widthAnchor.constraint(equalToConstant: 0)
            lcLoadingViewWidth?.isActive = true
            loadingView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        }

        updateFromProgress()
    }

    private func updateFromProgress() {
        if SyncService.shared.isSyncing {
            loadingView.isHidden = false
            lcLoadingViewWidth?.constant = frame.size.width * CGFloat(SyncService.shared.syncProgress.fractionCompleted)
        } else {
            loadingView.isHidden = true
        }
    }

}
