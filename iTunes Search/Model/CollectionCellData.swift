//
//  CollectionCellData.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/05/21.
//

import Foundation

class CollectionCellData {
    let image: String
    let artistName: String
    let trackName: String
    let collectionName: String?

    init(image: String, artistName: String, trackName: String, collectionName: String) {
        self.image = image
        self.artistName = artistName
        self.trackName = trackName
        self.collectionName = collectionName
    }
}
