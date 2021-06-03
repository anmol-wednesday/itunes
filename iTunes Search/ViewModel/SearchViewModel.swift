//
//  SearchViewModel.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 24/05/21.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    public let defaults = UserDefaults.standard
    public var artistHits = [TableViewCellData]()
    public var resultName = ""
    public var selectedAPI = ""
	
	public var subject = PublishSubject<[TableViewCellData]>()
	
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
    
    func getAPIData(for value: String, completion: @escaping ([TableViewCellData]) -> Void) {
        selectedAPI = defaults.value(forKey: K.userDefaultsKey) as! String
        print("getAPIData called")
        if selectedAPI == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getArtists(search: value) { (namesResponse) in
					self?.artistHits = namesResponse // remove
					self?.subject.onNext(namesResponse)
                    completion(self!.artistHits) // remove closure
                }
            }
        } else if selectedAPI == API.Napster.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterArtists(value) { response in
                    self?.artistHits = response // remove
					self?.subject.onNext(response)
                }
                completion(self!.artistHits) // remove closure
            }
        }
    }
    
    func setupDetailVC(for indexPath: IndexPath) -> (String, String) {
        SearchViewController.selectedAPI == API.Apple.rawValue ? {
			resultName = ("\(artistHits[indexPath.row].artistNames) \(artistHits[indexPath.row].collectionNames ?? "")")
            selectedAPI = SearchViewController.selectedAPI
        }() : {
			resultName = artistHits[indexPath.row].artistNames
            selectedAPI = SearchViewController.selectedAPI
        }()
        return (resultName, selectedAPI)
    }
}
