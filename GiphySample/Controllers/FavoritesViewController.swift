//
//  FavoritesViewController.swift
//  GiphySample
//
//  Created by techjini on 07/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let favoritesViewModel = FavoritesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.errorLabel.isHidden = true
        activityIndicatorShouldAnimate(true, andHideTableView: true)
        fetchFavoriteGifs()
    }
    
    func setupUI(){
        view.backgroundColor = UIColor.blackRussian
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
    func fetchFavoriteGifs() {
        favoritesViewModel.fetchAllGifs { (isSuccess) in
            activityIndicatorShouldAnimate(false)
            self.collectionView.reloadData()
            self.errorLabel.isHidden = isSuccess
        }
    }
    
    func activityIndicatorShouldAnimate(_ isAnimated: Bool, andHideTableView isHidden: Bool = false) {
        DispatchQueue.main.async {
            self.collectionView.isHidden = isHidden
            if isAnimated {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func pushToDetailVC(for url: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        detailVC.gifImage = Utils.getGifFromLocal(url)
        detailVC.modalPresentationStyle = .overCurrentContext
        detailVC.modalTransitionStyle = .crossDissolve
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritesViewModel.numberOfGifs
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as? FavoriteCell else {
            return UICollectionViewCell()
        }
        
        guard let gifObject = favoritesViewModel.getGifObject(indexPath) else {
            return cell
        }
        cell.gifFavoritesDelegate = self
        cell.setData(gifObject)
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = favoritesViewModel.getGifObject(indexPath)?.id  else {
            return
        }
        pushToDetailVC(for: url+".gif")
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
}


extension FavoritesViewController: FavoritesCellDelegate {
    
    func removeGif(_ gif: Gif) {
        CoreDataManager.shared.delete(gif)
        fetchFavoriteGifs()
    }
    
}
