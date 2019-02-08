//
//  FavoritesViewModel.swift
//  GiphySample
//
//  Created by techjini on 08/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit

class FavoritesViewModel {
    
    private var gifList:[Gif]?
    
    var numberOfGifs: Int {
        return gifList?.count ?? 0
    }
    
    func getGifObject(_ indexPath: IndexPath) -> Gif? {
        return gifList?[indexPath.row]
    }
    
    func fetchAllGifs(completionHandler: (_ isSuccess: Bool) -> Void) {
        gifList = CoreDataManager.shared.fetchAllGifs()
        if numberOfGifs > 0 {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
}
