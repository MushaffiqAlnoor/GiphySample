//
//  SearchCell.swift
//  GiphySample
//
//  Created by techjini on 06/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit
import GiphyCoreSDK

protocol GifDownloadDelegate {
    func downloadGif(_ gif: Gif)
    func deleteGif(_ gif: Gif)
}

class SearchCell: UITableViewCell {
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var gifNameLabel: UILabel!
    
    var gifObject: GPHMedia?
    var gifDownloadDelegate: GifDownloadDelegate?
    
    func setData(_ gifObject: GPHMedia) {
        self.gifObject = gifObject
        setImage(nil)
        gifNameLabel.text = gifObject.title
    }
    
    func setImage(_ image: UIImage?) {
        gifImageView.image = image
        if image == nil {
            favoritesButton.isHidden = true
            favoritesButton.isSelected = false
        } else {
            favoritesButton.isHidden = false
            let gif = CoreDataManager.shared.fetch(withGifID: (gifObject?.id ?? ""))
            favoritesButton.isSelected = gif != nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setImage(nil)
    }
    
    @IBAction func favoritesButtonClicked(_ sender: UIButton) {
        self.favoritesButton.isSelected = !self.favoritesButton.isSelected
        sender.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.6),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        sender.transform = CGAffineTransform.identity
        },completion: { Void in()
                        
        })
        if favoritesButton.isSelected {
            downloadGif()
        } else {
            deleteGif()
        }
    }
    
    func getGif() -> Gif? {
        guard let gifObject = gifObject, let urlString = gifObject.images?.downsized?.gifUrl, let url = URL(string: urlString) else {
            return nil
        }
        return Gif(id: gifObject.id, url: url, title: gifObject.title)
    }
    
    func downloadGif() {
        guard let gif = getGif() else {
            return
        }
        gifDownloadDelegate?.downloadGif(gif)
    }
    
    func deleteGif() {
        guard let gif = getGif() else {
            return
        }
        gifDownloadDelegate?.deleteGif(gif)
    }
}
