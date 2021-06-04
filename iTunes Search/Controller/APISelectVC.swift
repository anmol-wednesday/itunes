//
//  APISelectVC.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 04/05/21.
//

import UIKit
import RxSwift
import RxCocoa

class APISelectVC: UITableViewController {
	let K = Constants()
	let disposeBag = DisposeBag()
	
	public let selectedAPI = PublishSubject<String>()
	let apiNames = BehaviorSubject<[String]>(value: [API.Apple.rawValue, API.Napster.rawValue])
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = nil
		tableView.dataSource = nil
		tableView.allowsMultipleSelection = false
		title = "Select API"
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.apiTable)
		
		bindToTable(named: tableView)
	}
		
	func bindToTable(named: UITableView) {
		apiNames.bind(to: tableView.rx.items(cellIdentifier: K.apiTable, cellType: UITableViewCell.self)) { _, item, cell in
			cell.textLabel?.text = item
			cell.accessoryType = .none
		}.disposed(by: disposeBag)
		
		tableView.rx.itemSelected.bind { [weak self] indexPath in
			let cell = self?.tableView.cellForRow(at: indexPath)
			let value = cell?.textLabel?.text!
			print(value!)
			self?.selectedAPI.onNext(value!)
			UserDefaults.standard.setValue(value!, forKey: self!.K.userDefaultsKey)
			self?.navigationController?.popViewController(animated: true)
		}.disposed(by: disposeBag)
	}
}
