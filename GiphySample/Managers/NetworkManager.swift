//
//  NetworkManager.swift
//  GiphySample
//
//  Created by techjini on 07/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private let session = URLSession.shared
    
    func loadData(from url: URL, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                completionHandler(nil, error)
            }
            
            if let unwrappedData = data {
                completionHandler(unwrappedData, nil)
            }
        }
        task.resume()
    }
}
