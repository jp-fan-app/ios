//
//  YoutubeService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation
import Alamofire
import SwiftyJSON
import CoreSpotlight
import MobileCoreServices


class YoutubeService {
    
    static let shared = YoutubeService()
    private let youtubeKey: String

    private let sessionManager: SessionManager
    private let baseURL = URL(string: "https://www.googleapis.com/youtube/v3")!

    init() {
        self.sessionManager = SessionManager.default
        self.youtubeKey = Keys.youtubeKey()
    }

    func fetchVideoDetails(forYoutubeID youtubeID: String,
                           completion: @escaping (JPYoutubeVideoDetail?) -> ()) {

        let params: [String: Any] = [
            "part": "contentDetails,snippet,statistics",
            "id": youtubeID,
            "key": youtubeKey
        ]

        sessionManager.request(baseURL.appendingPathComponent("videos"),
                               method: .get,
                               parameters: params,
                               encoding: URLEncoding.queryString,
                               headers: nil).responseData
        { response in
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(data: value)
                let detail = JPYoutubeVideoDetail(json: jsonValue)
                completion(detail)
            case .failure:
                completion(nil)
            }
        }
    }
    
    public func indexVideosForSpotlight() {
        var searchableItems = [CSSearchableItem]()
        
        for video in StorageService.shared.allYoutubeVideos() {
            let searchItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            searchItemAttributeSet.title = video.title
            searchItemAttributeSet.contentDescription = video.videoDescription
            searchItemAttributeSet.thumbnailURL = ImageCache.sharedInstance.cacheFileURLFor(imageWithId: video.id,
                                                                                            type: "video")
            let searchableItem = CSSearchableItem(uniqueIdentifier: "youtube:\(video.videoID)",
                                                  domainIdentifier: "com.pageler.christoph.jpperformance.youtube",
                                                  attributeSet: searchItemAttributeSet)
            searchableItems.append(searchableItem)
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) -> Void in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
        }
    }

}

// MARK: - Open Video

extension YoutubeService {

    func openYoutubeWithId(_ youtubeID: String) {
        if let youtubeURL = URL(string: urlToOpenInApp(youtubeID)) {
            if UIApplication.shared.openURL(youtubeURL) {
                return
            }
        }

        if let youtubeURL = URL(string: urlToOpenInSafari(youtubeID)) {
            UIApplication.shared.openURL(youtubeURL)
        } else {
            print("cant open url")
        }
    }

    private func urlToOpenInApp(_ youtubeID: String) -> String {
        return "youtube://www.youtube.com/watch?v=\(youtubeID)"
    }

    private func urlToOpenInSafari(_ youtubeID: String) -> String {
        return "https://www.youtube.com/watch?v=\(youtubeID)"
    }

}
