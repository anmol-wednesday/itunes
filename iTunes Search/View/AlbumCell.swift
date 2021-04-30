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
    
    func updateCell (album: Album) {
        let imageUrl = URL(string: album.artwork)
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: imageUrl!) {
                DispatchQueue.main.async {
                    self.songImage.image = UIImage(data: imageData)
                }
            }
        }
        songName.text = album.songName
        songArtist.text = album.artistName
    }
    
    func getNapsterCell(with albums: [String], name: String) {
        print("napster cell initialized...")
        let baseURL = "https://api.napster.com/imageserver/v2/albums/"
        let size = "200x200"
        let imageExtension = ".jpg"
        let imageURL = "\(baseURL)\(albums.first!)/images\(size)\(imageExtension)"
        if let url = URL(string: imageURL) {
            print(url)
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.songImage.image = UIImage(data: imageData)
                    }
                }
            }
        }
        songArtist.text = name
    }
}
