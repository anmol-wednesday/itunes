//
//  AlbumID.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 29/04/21.
//

import Foundation

struct AlbumID: Codable {
    let search: SearchID
}

struct SearchID: Codable {
    let data: DataResponseID
}

struct DataResponseID: Codable {
    let artists: [NapsterID]
}

struct NapsterID: Codable {
    let name: String
    let albumGroups: NapsterSongsID
}

struct NapsterSongsID: Codable {
    let singlesAndEPs: [String]?
}
