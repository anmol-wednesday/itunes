//
//  ViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    
    let K = Constants()
    let searchVC = SearchViewController()
    var resultName: String?
    var selectedAPI = ""
    
    var albums = [Album]()
    var napsterAlbums = [NapsterAlbums]()
    var cellData = [CollectionCellData]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: -40.0, bottom: 0.0, right: 0.0)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        collectionView.isHidden = false
        errorView.isHidden = true
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.description())
        getCollectionViewData(for: resultName!) { response in
            self.cellData = response
            self.spinner.performSelector(onMainThread: #selector(UIActivityIndicatorView.stopAnimating), with: nil, waitUntilDone: false)
            if self.cellData.isEmpty {
                DispatchQueue.main.async {
                    self.collectionView.isHidden = true
                    self.errorView.isHidden = false
                }
            }
        }
        title = resultName
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.description(), for: indexPath) as? AlbumCell {
            cell.updateCell(album: cellData[indexPath.row])
            
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ViewController {
    func getCollectionViewData(for value: String, completion: @escaping ([CollectionCellData]) -> Void) {
        if SearchViewController.selectedAPI == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let search = value
                SearchManager.instance.getAlbum(searchRequest: search) { [self] (requestedAlbums) in
                    self?.albums = requestedAlbums
                    
                    self?.cellData = self!.albums.map {
                        CollectionCellData(image: $0.artwork, artistName: $0.artistName, trackName: $0.songName, collectionName: $0.collectionName)
                        
                    }
                    completion(self!.cellData)
                }
            }
        } else if SearchViewController.selectedAPI == API.Napster.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterAlbums(string: value) { (request) in
                    self?.napsterAlbums = request
                    self?.cellData = self!.napsterAlbums[0].albumID.map {
                        CollectionCellData(image: $0, artistName: self!.resultName!, trackName: $0, collectionName: $0)
                    }
                    completion(self!.cellData)
                }
            }
        }
    }
}
