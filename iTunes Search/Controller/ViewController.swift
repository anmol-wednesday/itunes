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

    var resultName: String?
    var selectedAPI = ""
    
    var cellData = [CollectionCellData]()
    
    override func viewWillAppear(_ animated: Bool) {
        title = resultName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        print("Cell data in view controller : \(cellData)")
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
