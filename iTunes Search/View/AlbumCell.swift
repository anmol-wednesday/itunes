//
//  AlbumCell.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var collectionName: UILabel!
    
    func updateCell (album: CollectionCellData) {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageUrl = URL(string: album.image)
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl!) {
                    DispatchQueue.main.async {
                        self.songImage.image = UIImage(data: imageData)
                    }
                }
            }

        }
        songName.text = album.trackName
        songArtist.text = album.artistName
        collectionName.text = album.collectionName ?? ""
    }
    
    func getNapsterCell(with albums: CollectionCellData, name: String) {
        let baseURL = "https://api.napster.com/imageserver/v2/albums/"
        let size = "200x200"
        let imageExtension = ".jpg"
        
        songName.text = albums.image.uppercased()
        collectionName.text = albums.image.uppercased()
        DispatchQueue.global(qos: .userInitiated).async {
            let imageURL = "\(baseURL)\(albums.image)/images/\(size)\(imageExtension)"
            if let url = URL(string: imageURL) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.songImage.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
        songArtist.text = name
    }
}
