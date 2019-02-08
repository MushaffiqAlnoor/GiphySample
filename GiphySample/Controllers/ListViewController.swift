//
//  ViewController.swift
//  GiphySample
//
//  Created by techjini on 06/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit
import SwiftGif

class ListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let homeViewModel = HomeViewModel()
    let downloadService = DownloadService()
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var searchString: String = "" {
        didSet {
            getGifs()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadService.downloadsSession = downloadsSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        getGifs()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.blackRussian
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        errorLabel.isHidden = true
    }
    
    func getGifs(_ withOffset: Bool = false) {
        if withOffset == false {
            homeViewModel.resetOffset()
            activityIndicatorShouldAnimate(true, andHideTableView: true)
        }
        homeViewModel.getGifs(searchString) { (isSuccess) in
            self.activityIndicatorShouldAnimate(false)
            DispatchQueue.main.async {
                if isSuccess {
                    self.listTableView.reloadData()
                }
                if self.homeViewModel.numberOfGifs == 0 {
                    self.errorLabel.isHidden = false
                    self.listTableView.isHidden = true
                } else {
                    self.errorLabel.isHidden = true
                    self.listTableView.isHidden = false
                }
                
            }
        }
    }
    
    func activityIndicatorShouldAnimate(_ isAnimated: Bool, andHideTableView isHidden: Bool = false) {
        DispatchQueue.main.async {
            self.listTableView.isHidden = isHidden
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
        detailVC.gifImage = UIImage.gif(url: url)
        detailVC.modalPresentationStyle = .overCurrentContext
        detailVC.modalTransitionStyle = .crossDissolve
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.numberOfGifs
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListCell", for: indexPath) as? SearchCell else {
            return UITableViewCell()
        }
        
        let gifObject = homeViewModel.getGifObject(indexPath)
        cell.gifDownloadDelegate = self
        cell.setData(gifObject)
        
        guard let url = gifObject.images?.fixedWidth?.gifUrl else {
            return UITableViewCell()
        }
        
        if indexPath.row == homeViewModel.numberOfGifs - 1 {
            getGifs(true)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage.gif(url: url)
            DispatchQueue.main.async {
                if let updateCell = tableView.cellForRow(at: indexPath) as? SearchCell {
                    updateCell.setImage(image)
                }
            }
        }
        
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = homeViewModel.getGifObject(indexPath).images?.downsized?.gifUrl  else {
            return
        }
        pushToDetailVC(for: url)
    }
}

extension ListViewController: UISearchBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        searchString = searchBar.text ?? ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchString = ""
        }
    }
}

extension ListViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        guard let download = downloadService.activeDownloads[sourceURL] else { return }
        downloadService.activeDownloads[sourceURL] = nil
        
        let filePath = String(download.gif.id) + ".gif"
        let destinationURL = Utils.getLocalFilePath(filePath)
        print(destinationURL)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            CoreDataManager.shared.insert(download.gif)
            print("Saved successfully.")
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
    }
}


extension ListViewController: GifDownloadDelegate {
    func downloadGif(_ gif: Gif) {
        downloadService.startDownload(gif)
    }
    
    func deleteGif(_ gif: Gif) {
        CoreDataManager.shared.delete(gif)
        downloadService.cancelDownload(gif)
    }
}
