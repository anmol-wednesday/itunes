//
//  SearchViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 21/04/21.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchTable: UITableView!
    var spinner: UIActivityIndicatorView!
    
    let viewModel = SearchViewModel()
    
    let K = Constants()
    let searchController = UISearchController(searchResultsController: nil)
    var timer: Timer?
    
    static var selectedAPI = "Select API"
    var artistHits = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
        }
    }
    var collections = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
        }
    }
    var searchQuery = ""
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.setSelectedAPI()
        let apiSelect = UIBarButtonItem(title: defaults.object(forKey: K.userDefaultsKey) as? String, style: .plain, target: self, action: #selector(promptAPISelect))
        navigationItem.rightBarButtonItems = [apiSelect]
        viewModel.selectedAPI(name: SearchViewController.selectedAPI)
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
                self.spinner.stopAnimating()
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
        spinner.isHidden = false
        spinner.startAnimating()
        print("Method called by \(searchController.searchBar.text!)")
        let search = searchController.searchBar.text!
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.getAPIData(for: search) { [weak self] artists, collection in
                self?.artistHits = artists
                self?.collections = collection
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
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
        let detail = ViewController()
        (detail.resultName, detail.selectedAPI) = viewModel.setupDetailVC(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        navigationController?.pushViewController(detail, animated: true)
    }
}
//MARK: - Class methods

extension SearchViewController {
    @objc func promptAPISelect() {
        let apiSelectVC = APISelectVC()
        navigationController?.pushViewController(apiSelectVC, animated: true)
    }
    
    func setupViews() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        title = "Search"
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter artist name"
        
        searchTable = UITableView()
        self.view.addSubview(searchTable)
        searchTable.delegate = self
        searchTable.dataSource = self
        searchTable.translatesAutoresizingMaskIntoConstraints = false
        searchTable.register(CustomCell.self, forCellReuseIdentifier: K.searchTable)
        
        spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        searchTable.addSubview(spinner)
        spinner.isHidden = true
        
        NSLayoutConstraint.activate([
            searchTable.topAnchor.constraint(equalTo: view.topAnchor),
            searchTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
