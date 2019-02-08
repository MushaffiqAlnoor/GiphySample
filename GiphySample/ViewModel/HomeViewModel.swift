//
//  HomeViewModel.swift
//  GiphySample
//
//  Created by techjini on 07/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit
import GiphyCoreSDK

class HomeViewModel {
    
    private var gifList:[GPHMedia]?
    private let maxLimit = 25
    private var offset = 0
    
    var numberOfGifs: Int {
        return gifList?.count ?? 0
    }
    
    func resetOffset() {
        offset = 0
        gifList = nil
    }
    
    func getGifObject(_ indexPath: IndexPath) -> GPHMedia {
        return gifList?[indexPath.row] ?? GPHMedia()
    }
    
    func getGifs(_ searchString: String, completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        if searchString == "" {
            GiphyCore.shared.trending(GPHMediaType.gif, offset: offset, limit: maxLimit, rating: GPHRatingType.ratedR, completionHandler: { (data, error) in
                guard let gifList = data?.data, error == nil else {
                    completionHandler(false)
                    return
                }
                self.gifList = (self.gifList ?? []) + gifList
                self.offset = self.numberOfGifs
                if self.numberOfGifs > 0 {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            })
        } else {
            GiphyCore.shared.search(searchString, media: GPHMediaType.gif, offset: offset, limit: maxLimit, rating: GPHRatingType.ratedR, lang: GPHLanguageType.english) { (data, error) in
                guard let gifList = data?.data, error == nil else {
                    completionHandler(false)
                    return
                }
                self.gifList = (self.gifList ?? []) + gifList
                self.offset = self.numberOfGifs
                if self.numberOfGifs > 0 {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        }
    }
    
    func getImage(_ id: String, fromURL urlString: String, completionHandler: @escaping (_ data: Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        NetworkManager.shared.loadData(from: url) { (data, error) in
            guard let data = data else {
                return
            }
            completionHandler(data)
        }
    }
}
