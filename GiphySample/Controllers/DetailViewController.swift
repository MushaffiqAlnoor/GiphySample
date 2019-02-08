//
//  DetailViewController.swift
//  GiphySample
//
//  Created by techjini on 07/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    var gifImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.setImage(UIImage(named: "Close")?.withColor(color: .white), for: .normal)
        gifImageView.image = gifImage
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
