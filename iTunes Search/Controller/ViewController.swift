//
//  ViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    let K = Constants()
    let searchVC = SearchViewController()
    let errorView: EmptyView = {
        let view = EmptyView()
        return view
    }()
    
    var resultName: String?
    var selectedAPI = ""
    var spinner: UIActivityIndicatorView!
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
        view.backgroundColor = UIColor(named: "viewColor")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if view.frame.size.width == 320 {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            layout.sectionInset = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        }
        layout.itemSize = CGSize(width: 300, height: 100)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor(named: "viewColor")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = false
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        view.addSubview(errorView)
        view.addSubview(spinner)
        
        setConstraints()
        
        self.errorView.isHidden = true
        
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
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            errorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            errorView.widthAnchor.constraint(equalToConstant: 300),
            errorView.heightAnchor.constraint(equalToConstant: 95),
            
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            spinner.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
