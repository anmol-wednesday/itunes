//
//  NapsterAlbums.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 29/04/21.
//

import Foundation

class NapsterAlbums {
    var albumID: [String]
    var artistName: String
    
    init(albumID: [String], artistName: String) {
        self.albumID = albumID
        self.artistName = artistName
    }
}
