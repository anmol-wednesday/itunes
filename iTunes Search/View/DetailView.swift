//
//  DetailView.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 25/05/21.
//

import UIKit

class DetailView: UIView {
    
    var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        if self.frame.size.width == 320 {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            layout.sectionInset = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        }
        layout.itemSize = CGSize(width: 300, height: 100)
        
        collectionView = {
            let collection = UICollectionView(frame: self.frame, collectionViewLayout: layout)
            collection.translatesAutoresizingMaskIntoConstraints = false
            collection.sizeToFit()
            collection.backgroundColor = UIColor(named: "viewColor")
            return collection
        }()
        setupView()
    }
    
    var spinner: UIActivityIndicatorView = {
        let spin = UIActivityIndicatorView(style: .large)
        spin.hidesWhenStopped = true
        spin.translatesAutoresizingMaskIntoConstraints = false
        spin.isHidden = true
        return spin
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        addSubview(spinner)
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
