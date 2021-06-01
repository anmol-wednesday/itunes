//
//  CollectionCoordinator.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 01/06/21.
//

import UIKit

class CollectionCoordinator: Coordinator {

	private let presenter: UINavigationController
	private var collectionVC: ViewController?
	private var resultName: String
	private var selectedAPI: String
	
	init(presenter: UINavigationController, resultName: String, selectedAPI: String) {
		self.presenter = presenter
		self.resultName = resultName
		self.selectedAPI = selectedAPI
	}
	
	func start() {
		let detail = ViewController()
		detail.resultName = resultName
		detail.selectedAPI = selectedAPI
		self.collectionVC = detail
		presenter.pushViewController(detail, animated: true)
	}
}
