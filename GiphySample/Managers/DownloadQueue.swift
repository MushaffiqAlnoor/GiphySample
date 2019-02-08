//
//  DownloadQueue.swift
//  GiphySample
//
//  Created by techjini on 07/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit

class Gif {
    var id: String
    var url: URL?
    var title: String?
    
    init(id: String, url: URL?, title: String?) {
        self.id = id
        self.title = title
        self.url = url
    }
}

class DownloadGif {
    var gif: Gif
    var task: URLSessionDownloadTask?
    var isDownloading = false
    
    init(gif: Gif) {
        self.gif = gif
    }
}

class DownloadService {
    var downloadsSession: URLSession!
    var activeDownloads: [URL: DownloadGif] = [:]
    
    func startDownload(_ gif: Gif) {
        guard let url = gif.url else {
            return
        }
        let download = DownloadGif(gif: gif)
        download.task = downloadsSession.downloadTask(with: url)
        download.task!.resume()
        download.isDownloading = true
        activeDownloads[url] = download
    }
    
    func cancelDownload(_ gif: Gif) {
        if let url = gif.url, let download = activeDownloads[url] {
            download.task?.cancel()
            activeDownloads[url] = nil
        }
    }
}
