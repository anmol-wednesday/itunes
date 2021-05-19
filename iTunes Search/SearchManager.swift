//
//  SearchManager.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import Foundation

class SearchManager {
    
    var selectedAPI = ""
    let K = Constants()
    static let instance = SearchManager()
    
    func makeAPICall(searchQuery: String, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let url = makeURL(for: searchQuery)
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { data, response, error in
            completion(data, response, error)
        }.resume()
    }

    func getAlbum(searchRequest: String, completion: @escaping ([Album]) -> Void) {
        var albums = [Album]()
        makeAPICall(searchQuery: searchRequest) { data, _, error in
            if let safeData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: safeData, options: []) as? [String: Any]
                    if let albumResults = json!["results"] as? NSArray {
                        
                        for album in albumResults {
                            if let albumInfo = album as? [String: AnyObject] {
                                guard let artworkUrl100 = albumInfo["artworkUrl100"] as? String else {return}
                                guard let trackName = albumInfo["trackName"] as? String else {return}
                                guard let artistName = albumInfo["artistName"] as? String else {return}
                                guard let detail = albumInfo["collectionName"] as? String else {return}
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
        }
    }
    
    func getArtists(search: String, completion: @escaping (([String], [String])) -> Void) {
        var artists = [String]()
        var collections = [String]()
        makeAPICall(searchQuery: search) { data, _, error in
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
        }
    }
    
    func getNapsterArtists(_ searchString: String, completion: @escaping ([String]) -> Void) {
        var artistName = [String]()
        let url = makeURL(for: searchString)
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
    
    func parseJSON(_ data: Data) -> [NapsterAlbums] {
        let decoder = JSONDecoder()
        var temp = [NapsterAlbums]()
        var albumID: [String] = []
        do {
            let decodedData = try decoder.decode(AlbumID.self, from: data)
            if let albumJSON = decodedData.search.data.artists.first!.albumGroups.singlesAndEPs {
                albumID = albumJSON
            }
            let albumInfo = NapsterAlbums(albumID: albumID) //change
            temp.append(albumInfo)
        } catch {
            print(error)
        }
        return temp
    }

    func getNapsterAlbums(string: String, completion: @escaping ([NapsterAlbums]) -> Void) {
        var napsterAlbums: [NapsterAlbums] = []
        makeAPICall(searchQuery: string) { data, _, error in
            if error != nil {
                print(error!)
                return
            }
            if let safeData = data {
                napsterAlbums = self.parseJSON(safeData)
                completion(napsterAlbums)
            }
        }
    }
    
    func makeURL(for searchQuery: String) -> URL {
        let searchString = searchQuery.replacingOccurrences(of: " ", with: "+")
        
        var components = URLComponents()
        
        components.scheme = K.scheme
        
        if selectedAPI == API.Apple.rawValue {
            components.host = K.appleHost
            components.path = K.applePath
            components.queryItems = [
                URLQueryItem(name: "term", value: searchString)
            ]
        } else {
            components.host = K.napsterHost
            components.path = K.napsterPath
            components.queryItems = [
                URLQueryItem(name: "apikey", value: K.napsterKey),
                URLQueryItem(name: "type", value: "artist"),
                URLQueryItem(name: "query", value: searchQuery)
            ]
        }
        
        guard let url = components.url else { fatalError("Cannot create URL") }
        return url
    }
}
