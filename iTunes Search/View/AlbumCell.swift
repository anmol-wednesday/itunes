//
//  AlbumCell.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let songNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "System", size: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let collectionNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpView() {
        
        contentView.backgroundColor = .red
        addSubview(albumImageView)
        addSubview(songNameLabel)
        addSubview(artistNameLabel)
        addSubview(collectionNameLabel)
        
        NSLayoutConstraint.activate([
            //albumImageView constraints
            self.leadingAnchor.constraint(equalTo: albumImageView.leadingAnchor, constant: 0.0),
            self.topAnchor.constraint(equalTo: albumImageView.topAnchor, constant: 0.0),
            albumImageView.widthAnchor.constraint(equalToConstant: 120.0),
            albumImageView.heightAnchor.constraint(equalToConstant: 120.0),
            
            // songNameLabel constraints
            songNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 10.0),
            songNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            songNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
        
            
            // songNameLabel constraints
            artistNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 10.0),
            artistNameLabel.topAnchor.constraint(equalTo: songNameLabel.bottomAnchor, constant: 8.0),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
            

            // songNameLabel constraints
            collectionNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 10.0),
            collectionNameLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 8.0),
            collectionNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0)
        ])
    }
    
    let defaults = UserDefaults.standard
    let K = Constants()
    
    func updateCell(album: CollectionCellData) {
        if defaults.object(forKey: K.userDefaultsKey) as? String == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async {
                let imageUrl = URL(string: album.image)
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: imageUrl!) {
                        DispatchQueue.main.async {
                            self.albumImageView.image = UIImage(data: imageData)
                        }
                    }
                }
            }
            songNameLabel.text = album.trackName
            artistNameLabel.text = album.artistName
            collectionNameLabel.text = album.collectionName ?? ""
        }
        
        if defaults.object(forKey: K.userDefaultsKey) as? String == API.Napster.rawValue {
            let baseURL = "https://api.napster.com/imageserver/v2/albums/"
            let size = "200x200"
            let imageExtension = ".jpg"
            
            songNameLabel.text = album.image.uppercased()
            collectionNameLabel.text = album.image.uppercased()
            DispatchQueue.global(qos: .userInitiated).async {
                let imageURL = "\(baseURL)\(album.image)/images/\(size)\(imageExtension)"
                if let url = URL(string: imageURL) {
                    DispatchQueue.global().async {
                        if let imageData = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                self.albumImageView.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
            artistNameLabel.text = album.artistName
        }
    }
}
