//
//  NapsterAlbums.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 29/04/21.
//

import Foundation
import UIKit

class NapsterAlbums {
    var trackName: [String]
    var artistName: String
    var albumID: [String]
    
    init(trackName: [String], artistName: String, albumID: [String]) {
        self.trackName = trackName
        self.artistName = artistName
        self.albumID = albumID
    }
}
