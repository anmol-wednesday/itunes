//
//  APISelectCoordinator.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 31/05/21.
//

import UIKit

class APISelectCoordinator: Coordinator {
	
	private let presenter: UINavigationController
	private var searchTableCoordinator: SearchTableCoordinator?
	private var apiViewController: APISelectVC?
	
	init(presenter: UINavigationController) {
		self.presenter = presenter
	}
	
	func start() {
		let APISelectVC = APISelectVC()
		self.apiViewController = APISelectVC
		presenter.pushViewController(APISelectVC, animated: true)
		searchTableCoordinator?.start()
	}
}
