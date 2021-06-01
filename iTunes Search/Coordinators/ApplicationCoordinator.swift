//
//  ApplicationCoordinator.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 01/06/21.
//

import UIKit

class ApplicationCoordinator: Coordinator {
	
	private let window: UIWindow
	private let rootViewController: UINavigationController
	private let searchTableCoordinator: SearchTableCoordinator?
	private var searchVC: SearchViewController?
	
	init(window: UIWindow) {
		self.window = window
		searchVC = SearchViewController()
		rootViewController = UINavigationController(rootViewController: searchVC!)
		rootViewController.navigationBar.prefersLargeTitles = true
		
		searchTableCoordinator = SearchTableCoordinator(presenter: rootViewController)
	}
	
	func start() {
		window.rootViewController = rootViewController
		window.makeKeyAndVisible()
	}
}
