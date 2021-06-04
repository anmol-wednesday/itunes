//
//  SearchTableCoordinator.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 31/05/21.
//

import UIKit

class SearchTableCoordinator: Coordinator {
	
	private let presenter: UINavigationController
	private var searchVC: SearchViewController?
	private var apiCoordinator: APISelectCoordinator?
	private var collectionCoordinator: CollectionCoordinator?
	
	init(presenter: UINavigationController) {
		self.presenter = presenter
	}
	
	func start() {
		searchVC = SearchViewController()
		searchVC?.delegate = self
		presenter.pushViewController(searchVC!, animated: true)
	}
}

extension SearchTableCoordinator: SearchViewControllerDelegate {
	func didTapSelectAPI(_ controller: SearchViewController) {
		let apiCoordinator = APISelectCoordinator(presenter: presenter)
		self.apiCoordinator = apiCoordinator
		apiCoordinator.start()
	}
	
	func didTapCellInList(_ controller: SearchViewController, resultName: String, selectedAPI: String) {
		let collectionCoordinator = CollectionCoordinator(presenter: presenter, resultName: resultName, selectedAPI: selectedAPI)
		self.collectionCoordinator = collectionCoordinator
		collectionCoordinator.start()
	}
}
