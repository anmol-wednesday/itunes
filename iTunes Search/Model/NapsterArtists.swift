//
//  NapsterArtists.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 28/04/21.
//

import Foundation

struct NapsterArtists: Codable {
    let search: Search
}

struct Search: Codable {
    let data: DataResponse
}

struct DataResponse: Codable {
    let artists: [Napster]
}

struct Napster: Codable {
    var name: String
}
