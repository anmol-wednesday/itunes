//
//  SearchTableCoordinator.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 31/05/21.
//

import UIKit

class SearchTableCoordinator: Coordinator {
    
	private let presenter: UINavigationController
	private var detailVC: ViewController?
    
	init(presenter: UINavigationController) {
		self.presenter = presenter
	}
	
    func start() {
		let detail = ViewController()
		self.detailVC = detail
		presenter.pushViewController(detail, animated: true)
    }
}
