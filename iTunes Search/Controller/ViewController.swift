//
//  ViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let viewModel = ViewModel()
    let searchVC = SearchViewController()
    
    let detailView: DetailView = {
        let view = DetailView()
        view.backgroundColor = UIColor(named: "viewColor")
        return view
    }()
    
    let errorView: EmptyView = {
        let view = EmptyView()
        return view
    }()
    
    var resultName: String?
    var selectedAPI = ""
    
    var albums = [Album]()
    var napsterAlbums = [NapsterAlbums]()
    var cellData = [CollectionCellData]() {
        didSet {
            DispatchQueue.main.async {
                self.detailView.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(detailView)
        setupViews()
        
        detailView.collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.description())
        viewModel.getCollectionViewData(for: resultName!) { [weak self] response in
            self?.cellData = response
            self?.detailView.spinner.performSelector(onMainThread: #selector(UIActivityIndicatorView.stopAnimating), with: nil, waitUntilDone: false)
            if self!.cellData.isEmpty {
                DispatchQueue.main.async {
                    self?.detailView.collectionView.isHidden = true
                    self?.errorView.isHidden = false
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
    func setupViews() {
        detailView.collectionView.delegate = self
        detailView.collectionView.dataSource = self
        detailView.collectionView.isHidden = false
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        detailView.spinner.startAnimating()
        
        view.addSubview(detailView)
        detailView.addSubview(errorView)
        errorView.isHidden = true
        
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.topAnchor),
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            errorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            errorView.widthAnchor.constraint(equalToConstant: 300),
            errorView.heightAnchor.constraint(equalToConstant: 95)
        ])
    }
}
