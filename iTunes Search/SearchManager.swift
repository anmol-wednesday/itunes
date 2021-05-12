//
//  SearchManager.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import Foundation

class SearchManager {
    var baseURL = ""
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
                                guard let detail = albumInfo["collectionName"] as? String else { return }
                                let albumInstance = Album(artwork: artworkUrl100, songName: trackName, artistName: artistName, collectionName: detail)
                                albums.append(albumInstance)
                            }
                        }
                        completion(albums)
                    }
                } catch {
                    print(error)
                }
            }
            if error != nil {
                print(error!)
            }
        }.resume()
    }
    
    func getArtists(search: String, completion: @escaping (([String], [String])) -> Void) {
        var artists = [String]()
        var collections = [String]()
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
                                    guard let collectionName = artistInfo["collectionName"] as? String else { return }

                                    let artist = Artists(name: artistName)
                                    artists.append(artist.name)
                                    
                                    let collection = Collection(collectionName: collectionName)
                                    collections.append(collection.collectionName)
                                }
                            }
                            completion((artists, collections))
                        }
                    } catch {
                        print(error)
                    }
                }
                if error != nil {
                    print(error!)
                }
            }.resume()
        }
    }
    
    func getNapsterArtists(_ searchString: String, completion: @escaping ([String]) -> Void) {
        var artistName = [String]()
        let search = searchString.replacingOccurrences(of: " ", with: "+")
        if let url = URL(string: "\(baseURL)\(search)") {
            if let data = try? Data(contentsOf: url) {
                let decoder = JSONDecoder()
                if let jsonArtists = try? decoder.decode(NapsterArtists.self, from: data) {
                    for names in jsonArtists.search.data.artists {
                        artistName.append(names.name)
                    }
                    completion(artistName)
                }
            }
        }
    }
    
    func parseJSON(_ data: Data) -> [NapsterAlbums] {
        let decoder = JSONDecoder()
        var temp = [NapsterAlbums]()
        var albumID: [String] = []
        
        do {
            let decodedData = try decoder.decode(AlbumID.self, from: data)
            if let albumJSON = decodedData.search.data.artists.first!.albumGroups.singlesAndEPs {
                albumID = albumJSON
            }
            let artistName = decodedData.search.data.artists.first!.name //x
            let albumInfo = NapsterAlbums(albumID: albumID, artistName: artistName) //change
            temp.append(albumInfo)
        } catch {
            print(error)
        }
        return temp
    }
    
    func getNapsterAlbums(string: String, completion: @escaping ([NapsterAlbums]) -> Void) {
        var napsterAlbums: [NapsterAlbums] = []
        let searchString = string.replacingOccurrences(of: " ", with: "+")
        if let url = URL(string: "\(baseURL)\(searchString)") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    napsterAlbums = self.parseJSON(safeData)
                    completion(napsterAlbums)
                }
            }
            task.resume()
        }
    }
}
