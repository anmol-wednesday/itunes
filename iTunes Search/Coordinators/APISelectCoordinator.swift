//
//  APISelectCoordinator.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 31/05/21.
//

import UIKit
import RxSwift
import RxCocoa

class APISelectCoordinator: Coordinator {
	
	private let presenter: UINavigationController
	private var searchTableCoordinator: SearchTableCoordinator?
	private var apiViewController: APISelectVC?
	private let disposeBag = DisposeBag()
	private let K = Constants()
	
	init(presenter: UINavigationController) {
		self.presenter = presenter
		
	}
	
	func start() {
		let APISelectVC = APISelectVC()
		self.apiViewController = APISelectVC
		APISelectVC.selectedAPI.subscribe(onNext: { value in
			print(value)
			SearchViewController.selectedAPI = value
			SearchManager.instance.selectedAPI = value
			UserDefaults.standard.setValue(value, forKey: self.K.userDefaultsKey)
		}).disposed(by: disposeBag)
		presenter.pushViewController(APISelectVC, animated: true)
	}
}
