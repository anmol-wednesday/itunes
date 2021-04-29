//
//  NapsterAlbums.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 29/04/21.
//

import Foundation

class NapsterAlbums {
    var trackName: String
    var artistName: String
    var albumArtwork: String
    
    init(trackName: String, artistName: String, albumArtwork: String) {
        self.trackName = trackName
        self.artistName = artistName
        self.albumArtwork = albumArtwork
    }
}
