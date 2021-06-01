//
//  SearchViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 21/04/21.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
	func didTapSelectAPI(_ controller: SearchViewController)
	func didTapCellInList(_ controller: SearchViewController, resultName: String, selectedAPI: String)
}

class SearchViewController: UIViewController {
	
	weak var delegate: SearchViewControllerDelegate?
	
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
    var artistHits = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.searchView.searchTable.reloadData()
            }
        }
    }
    var collections = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.searchView.searchTable.reloadData()
            }
        }
    }
    var searchQuery = ""
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchView)
        setupViews()
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
    
    //MARK: - Search Bar and Controller Delegates

extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        if searchText.isEmpty {
            artistHits = []
            collections = []
            DispatchQueue.main.async {
                self.searchView.spinner.stopAnimating()
            }
        } else {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(callAPI), userInfo: nil, repeats: false)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        artistHits = []
        collections = []
    }
    
    @objc func callAPI() {
        searchView.spinner.isHidden = false
        searchView.spinner.startAnimating()
        print("Method called by \(searchController.searchBar.text!)")
        let search = searchController.searchBar.text!
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.getAPIData(for: search) { [weak self] artists, collection in
                self?.artistHits = artists
                self?.collections = collection
                DispatchQueue.main.async {
                    self?.searchView.spinner.stopAnimating()
                }
            }
        }
    }
}

//MARK: - UITableView Delegate and Datasource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistHits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.searchTable, for: indexPath)
        
        if SearchViewController.selectedAPI == API.Apple.rawValue {
            cell.textLabel?.text = artistHits[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.text = collections[indexPath.row]
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        } else if SearchViewController.selectedAPI == API.Napster.rawValue {
            cell.textLabel?.text = artistHits[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.text = nil
        }
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
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        title = "Search"
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter artist name"
        
        searchView.searchTable.delegate = self
        searchView.searchTable.dataSource = self
        searchView.searchTable.register(CustomCell.self, forCellReuseIdentifier: K.searchTable)
        
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.topAnchor),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
