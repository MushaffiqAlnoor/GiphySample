//
//  FavoriteCollectionViewCell.swift
//  GiphySample
//
//  Created by techjini on 07/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit

protocol FavoritesCellDelegate {
    func removeGif(_ gif: Gif)
}

class FavoriteCell: UICollectionViewCell {
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var gifObject: Gif?
    var gifFavoritesDelegate: FavoritesCellDelegate?
    
    func setData(_ gif: Gif) {
        self.gifObject = gif
        favoritesButton.isSelected = true
        let fileName = String(gifObject?.id ?? "")+".gif"
        setImage(Utils.getGifFromLocal(fileName))
    }
    
    func setImage(_ image: UIImage?) {
        gifImageView.image = image
        if image == nil {
            favoritesButton.isHidden = true
        } else {
            favoritesButton.isHidden = false
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
        
        if favoritesButton.isSelected == false {
            removeGif()
        }
    }
    
    func removeGif() {
        guard let gif = gifObject else {
            return
        }
        gifFavoritesDelegate?.removeGif(gif)
    }
    
}
