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

    var resultName: String = ""
    var selectedAPI = ""
    
    var cellData = [CollectionCellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        title = resultName
        
        print(cellData)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of items\(cellData.count)")
        return cellData.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellforitem \(cellData.count)")
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell {
            if selectedAPI == K.apple {
                print("Index in cell for item\(indexPath.row)")
                cell.updateCell(album: cellData[indexPath.row])
            }
            if selectedAPI == K.napster {
                cell.getNapsterCell(with: cellData[indexPath.row], name: resultName)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}
