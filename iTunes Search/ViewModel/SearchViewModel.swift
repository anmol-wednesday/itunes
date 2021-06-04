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
    public var resultName = ""
    public var selectedAPI = ""
	let disposeBag = DisposeBag()
	
	public var subject = PublishSubject<[TableViewCellData]>()
	
    let K = Constants()
    
    func getAPIData(for value: String) {
		let defaults = UserDefaults.standard.string(forKey: K.userDefaultsKey)
        print("getAPIData called")
        if defaults == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getArtists(search: value) { response in
					self?.subject.onNext(response)
                }
            }
        } else if defaults == API.Napster.rawValue {
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
