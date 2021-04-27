//
//  SearchManager.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import Foundation

let baseURL = "https://itunes.apple.com/search?term="

class SearchManager {
    static let instance = SearchManager()
    func getAlbum(searchRequest: String, completion: @escaping ([Album]) -> Void) {
        var albums = [Album]()
        let searchString = searchRequest.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "\(baseURL)\(searchString)")
        let session = URLSession.shared
        session.dataTask(with: url!) { (data, _, error) in
            if let safeData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: safeData, options: []) as? [String: Any]
                    if let albumResults = json!["results"] as? NSArray {
                        for album in albumResults {
                            if let albumInfo = album as? [String: AnyObject] {
                                guard let artworkUrl100 = albumInfo["artworkUrl100"] as? String else {return}
                                guard let trackName = albumInfo["trackName"] as? String else {return}
                                guard let artistName = albumInfo["artistName"] as? String else {return}
                                let albumInstance = Album(artwork: artworkUrl100, songName: trackName, artistName: artistName)
                                albums.append(albumInstance)
                            }
                        }
                        completion(albums)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            if error != nil {
                print(error!.localizedDescription)
            }
        }.resume()
    }
    func getArtists(search: String, completion: @escaping ([Artists]) -> Void) {
        var artists = [Artists]()
        let search = search.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "\(baseURL)\(search)")
        let session = URLSession.shared
        if let safeURL = url {
            session.dataTask(with: safeURL) { (data, _, error) in
                if let safeData = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: safeData, options: []) as? [String: Any]
                        if let artistResults = json!["results"] as? NSArray {
                            for artist in artistResults {
                                if let artistInfo = artist as? [String: AnyObject] {
                                    guard let artistName = artistInfo["artistName"] as? String else { return }

                                    let artist = Artists(name: artistName)
                                    artists.append(artist)
                                }
                            }
                            completion(artists)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if error != nil {
                    print(error!.localizedDescription)
                }
            }.resume()
        }
        print(artists)
    }
}
