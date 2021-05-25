//
//  SearchViewModel.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 24/05/21.
//

import Foundation

class SearchViewModel {
    public let defaults = UserDefaults.standard
    public let artistHits = [String]()
    public let collections = [String]()
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
}
