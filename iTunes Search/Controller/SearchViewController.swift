//
//  SearchViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 21/04/21.
//

import UIKit
import RxSwift
import RxCocoa

protocol SearchViewControllerDelegate: AnyObject {
	func didTapSelectAPI(_ controller: SearchViewController)
	func didTapCellInList(_ controller: SearchViewController, resultName: String, selectedAPI: String)
}

class SearchViewController: UIViewController {//, UIScrollViewDelegate {
	
	weak var delegate: SearchViewControllerDelegate?
	let disposeBag = DisposeBag()
	let viewModel = SearchViewModel()
	
	let searchView: SearchView = {
		let view = SearchView()
		view.backgroundColor = UIColor(named: "viewColor")
		return view
	}()
	
	let K = Constants()
	let searchController = UISearchController(searchResultsController: nil)
	var timer: Timer?
	static var selectedAPI = "Select API"
	
	var artistHits = [TableViewCellData]() {
		didSet {
			
			DispatchQueue.main.async { [weak self] in
				self?.searchView.searchTable.reloadData()
			}
		}
	}
	
	var searchQuery = ""
	var defaults = UserDefaults.standard
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(searchView)
		setupViews()
		ObserveSearchBar()
		cancelButtonForSearchBar()
		searchView.searchTable.delegate = self
		searchView.searchTable.dataSource = self
//		searchView.searchTable.rx.setDelegate(self).disposed(by: disposeBag)
//		bindToTable()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		viewModel.setSelectedAPI()
		let apiSelect = UIBarButtonItem(title: defaults.object(forKey: K.userDefaultsKey) as? String, style: .plain, target: self, action: #selector(promptAPISelect))
		navigationItem.rightBarButtonItem = apiSelect
		apiSelect.accessibilityIdentifier = "apiButton"
		viewModel.selectedAPI(name: SearchViewController.selectedAPI)
	}
	
	@objc func promptAPISelect() {
		delegate?.didTapSelectAPI(self)
	}
}

//MARK: - UITableView Delegate and Datasource
//TODO: - Remove TableView Delegate and DataSource Methods
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return artistHits.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.searchTable, for: indexPath)
		cell.textLabel?.text = artistHits[indexPath.row].artistNames
		cell.detailTextLabel?.text = artistHits[indexPath.row].collectionNames
		cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let (result, api) = viewModel.setupDetailVC(for: indexPath)
		tableView.deselectRow(at: indexPath, animated: true)
		searchController.searchBar.resignFirstResponder()
		delegate?.didTapCellInList(self, resultName: result, selectedAPI: api)
	}
}
//MARK: - Class methods

extension SearchViewController {
	func setupViews() {
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.isTranslucent = true
		title = "Search"
		navigationItem.searchController = searchController
		
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.sizeToFit()
		searchController.searchBar.placeholder = "Enter artist name"
		
//		searchView.searchTable.register(CustomCell.self, forCellReuseIdentifier: K.searchTable)
		
		NSLayoutConstraint.activate([
			searchView.topAnchor.constraint(equalTo: view.topAnchor),
			searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			searchView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	func ObserveSearchBar() {
		searchController.searchBar.rx.text.subscribe { event in
			self.timer?.invalidate()
			if event.element!!.isEmpty {
				self.artistHits = []
				DispatchQueue.main.async {
					self.searchView.spinner.stopAnimating()
				}
			} else {
				self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.callAPI), userInfo: nil, repeats: false)
			}
		}.disposed(by: disposeBag)
	}
	
	@objc func callAPI() {
		searchView.spinner.isHidden = false
		searchView.spinner.startAnimating()
		print("Method called by \(searchController.searchBar.text!)")
		let search = searchController.searchBar.text!
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			self?.viewModel.getAPIData(for: search) { [weak self] artists in
				self?.artistHits = artists
				DispatchQueue.main.async {
					self?.searchView.spinner.stopAnimating()
				}
			}
		}
	}
	
	func cancelButtonForSearchBar() {
		searchController.searchBar.rx.cancelButtonClicked.subscribe { _ in
			self.artistHits = []
		}.disposed(by: disposeBag)
	}
	
	// Table View
//	func bindToTable() {
//
////		viewModel.subject.subscribe { results in
////			print(results)
////		}.disposed(by: disposeBag)
////
////		viewModel.subject2.subscribe(onNext: { results in
////			print(results)
////		}).disposed(by: disposeBag)
//
//		let table = searchView.searchTable
////		table.register(CustomCell.self, forCellReuseIdentifier: K.searchTable)
//		viewModel.subject.bind(to: table.rx.items(cellIdentifier: K.searchTable, cellType: CustomCell.self)) { (_, item, cell) in
//			cell.textLabel?.text = item
//			cell.detailTextLabel?.text = item
//			}.disposed(by: disposeBag)
//
////			viewModel.subject2.bind(to: table.rx.items(cellIdentifier: K.searchTable, cellType: CustomCell.self)) { (_, item, cell) in
////				cell.detailTextLabel?.text = item
////			}.disposed(by: disposeBag)
//
//	}
}
