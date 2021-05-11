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
    
    let K = Constants()
    let searchVC = SearchViewController()

    var resultName: String?
    var selectedAPI = ""
    
    var albums = [Album]()
    var napsterAlbums = [NapsterAlbums]()
    var cellData = [CollectionCellData]() {
        didSet {
            collectionView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: false)
        }
    }// add set property
    
    override func viewWillAppear(_ animated: Bool) {
        getCollectionViewData(for: resultName!) { response in
            self.cellData = response
            self.spinner.performSelector(onMainThread: #selector(UIActivityIndicatorView.stopAnimating), with: nil, waitUntilDone: false)
            if self.cellData.isEmpty {
                self.showAlert()
            }
        }
        title = resultName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell {
            if selectedAPI == API.Apple.rawValue {
                cell.updateCell(album: cellData[indexPath.row])
            }
            if selectedAPI == API.Napster.rawValue {
                cell.getNapsterCell(with: cellData[indexPath.row], name: resultName!)
            }
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
                SearchManager.instance.getAlbum(searchRequest: search) { (requestedAlbums) in
                    self?.albums = requestedAlbums
                    
                    for album in self!.albums {
                        let image = album.artwork
                        let name = album.artistName
                        let song = album.songName
                        let collection = album.collectionName
                        let cellInfo = CollectionCellData(image: image, artistName: name, trackName: song, collectionName: collection)
                        self?.cellData.append(cellInfo)
                    }
                    completion(self!.cellData)
                }
            }
        } else if SearchViewController.selectedAPI == API.Napster.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterAlbums(string: value) { (request) in
                    self?.napsterAlbums = request
                    if let counter = self?.napsterAlbums[0].albumID.count {
                        for i in 0..<counter {
                            let image = (self?.napsterAlbums[0].albumID[i])!
                            let name = value
                            let cellInfo = CollectionCellData(image: image, artistName: name, trackName: image, collectionName: image)
                            self?.cellData.append(cellInfo)
                        }
                        completion(self!.cellData)
                        
                    }
                }
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: K.errorTitle, message: "\(K.error)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
