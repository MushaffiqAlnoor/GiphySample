//
//  Utils.swift
//  GiphySample
//
//  Created by techjini on 08/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit
import SwiftGif

class Utils {
    static var getDocumentsDirectoryPath: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func getLocalFilePath(_ path: String) -> URL {
        return getDocumentsDirectoryPath.appendingPathComponent(path)
    }
    
    static func getGifFromLocal(_ id: String) -> UIImage? {
        let filePath = getDocumentsDirectoryPath.appendingPathComponent(id)
        guard let data = try? Data(contentsOf: filePath) else {
            return nil
        }
        return UIImage.gif(data: data)
    }
    
    static func removeGifFromLocal(_ id: String) {
        let fileManager = FileManager.default
        let filePath = getDocumentsDirectoryPath.appendingPathComponent(id)
        try? fileManager.removeItem(at: filePath)
    }
}


extension UIImage {
    func withColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
            
        }
    }
}
