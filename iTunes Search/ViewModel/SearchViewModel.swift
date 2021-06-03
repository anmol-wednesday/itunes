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
    
    func getAPIData(for value: String) {
        selectedAPI = defaults.value(forKey: K.userDefaultsKey) as! String
        print("getAPIData called")
        if selectedAPI == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getArtists(search: value) { (namesResponse) in
					self?.subject.onNext(namesResponse)
                }
            }
        } else if selectedAPI == API.Napster.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterArtists(value) { response in
					self?.subject.onNext(response)
                }
            }
        }
    }
    
	func setupDetailVC(for string: TableViewCellData?) -> (String, String) {
		guard let data = string else { fatalError("Failed to get model.") }
        SearchViewController.selectedAPI == API.Apple.rawValue ? {
			resultName = ("\(data.artistNames) \(data.collectionNames ?? "")")
            selectedAPI = SearchViewController.selectedAPI
        }() : {
			resultName = data.artistNames
            selectedAPI = SearchViewController.selectedAPI
        }()
        return (resultName, selectedAPI)
    }
}
