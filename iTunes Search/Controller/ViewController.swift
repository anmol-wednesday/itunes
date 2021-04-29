//
//  ViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!

    let K = Constants()
    
    var albums = [Album]()
    var napster = [NapsterAlbums]()
    var resultName: String = ""
    var selectedAPI = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        title = resultName
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell {
            if selectedAPI == K.apple {
                cell.updateCell(album: albums[indexPath.row])
            }
            if selectedAPI == K.napster {
                cell.getNapsterCell(with: napster[indexPath.row].albumID[indexPath.row])
            }
            return cell
        }
        collectionView.reloadData()
        return UICollectionViewCell()
    }
}
