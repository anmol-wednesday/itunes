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
        
        print(selectedAPI)
        print(napster)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 1
        if selectedAPI == K.apple {
            count = albums.count
        }
        if selectedAPI == K.napster {
            count = napster[0].albumID.count
        }
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell {
            cell.layer.borderColor = UIColor.black.cgColor
            if selectedAPI == K.apple {
                cell.updateCell(album: albums[indexPath.row])
            }
            if selectedAPI == K.napster {
                cell.getNapsterCell(with: napster[0].albumID[indexPath.row], name: resultName)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}
