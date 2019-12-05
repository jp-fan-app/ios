//
//  YoutubeFallbackVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 07.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


class YoutubeFallbackVC: UIViewController {

    @IBOutlet weak var buttonOpen: UIButton!
    var openVideoWithYoutubeID: String? = nil {
        didSet {
            updateButtonOpen()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateButtonOpen()
    }

    private func urlToOpenInApp() -> String {
        if let youtubeID = openVideoWithYoutubeID {
            return "youtube://www.youtube.com/watch?v=\(youtubeID)"
        }

        return "youtube:///user/JPPGmbH"
    }

    private func urlToOpenInSafari() -> String {
        if let youtubeID = openVideoWithYoutubeID {
            return "https://www.youtube.com/watch?v=\(youtubeID)"
        }

        return "https://www.youtube.com/user/JPPGmbH/videos"
    }

    private func deviceCanOpenUrlInYoutubeApp() -> Bool {
        guard let url = URL(string: urlToOpenInApp()) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    private func updateButtonOpen() {
        guard isViewLoaded else { return }

        if openVideoWithYoutubeID != nil {
            buttonOpen.setTitle("Open Video", for: .normal)
        } else {
            buttonOpen.setTitle("Open Channel", for: .normal)
        }
    }

    @IBAction func actionButtonOpen(_ sender: UIButton) {
        if deviceCanOpenUrlInYoutubeApp(), let youtubeURL = URL(string: urlToOpenInApp()) {
            UIApplication.shared.openURL(youtubeURL)
        } else if let youtubeURL = URL(string: urlToOpenInSafari()) {
            UIApplication.shared.openURL(youtubeURL)
        } else {
            print("cant open url")
        }
    }
}
