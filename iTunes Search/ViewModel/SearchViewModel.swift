//
//  SearchViewModel.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 24/05/21.
//

import Foundation

class SearchViewModel {
    public let defaults = UserDefaults.standard
    public var artistHits = [String]()
    public var collections = [String]()
    public var resultName = ""
    public var selectedAPI = ""
    
    let K = Constants()
    
    func selectedAPI(name: String) {
        if name == API.Apple.rawValue {
            SearchViewController.selectedAPI = name
            SearchManager.instance.selectedAPI = name
        } else if name == API.Napster.rawValue {
            SearchViewController.selectedAPI = name
            SearchManager.instance.selectedAPI = name
        }
    }
    
    func setSelectedAPI() {
        if defaults.object(forKey: K.userDefaultsKey) as? String == API.Apple.rawValue {
            selectedAPI(name: API.Apple.rawValue)
        } else if defaults.object(forKey: K.userDefaultsKey) as? String == API.Napster.rawValue {
            selectedAPI(name: API.Napster.rawValue)
        } else if defaults.object(forKey: K.userDefaultsKey) == nil {
            defaults.setValue("Select API", forKey: K.userDefaultsKey)
        }
    }
    
    func getAPIData(for value: String, completion: @escaping ([String], [String]) -> Void) {
        selectedAPI = defaults.value(forKey: K.userDefaultsKey) as! String
        print("getAPIData called")
        if selectedAPI == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getArtists(search: value) { (namesResponse, collectionsResponse) in
                    self?.artistHits = namesResponse
                    self?.collections = collectionsResponse
                    completion(self!.artistHits, self!.collections)
                }
            }
        } else if selectedAPI == API.Napster.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterArtists(value) { response in
                    self?.artistHits = response
                }
                self?.collections = []
                completion(self!.artistHits, self!.collections)
            }
        }
        
    }
    
    func setupDetailVC(for indexPath: IndexPath) -> (String, String) {
        SearchViewController.selectedAPI == API.Apple.rawValue ? {
            resultName = ("\(artistHits[indexPath.row]) \(collections[indexPath.row])")
            selectedAPI = SearchViewController.selectedAPI
        }() : {
            resultName = artistHits[indexPath.row]
            selectedAPI = SearchViewController.selectedAPI
        }()
        return (resultName, selectedAPI)
    }
}
