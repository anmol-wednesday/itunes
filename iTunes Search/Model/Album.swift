//
//  Album.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import Foundation

class Album{
    var artwork: String
    var songName: String
    var artistName: String
    
    init(artwork: String, songName: String, artistName: String) {
        self.artwork = artwork
        self.songName = songName
        self.artistName = artistName
    }
}
