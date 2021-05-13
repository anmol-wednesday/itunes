//
//  SearchViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 21/04/21.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchTable: UITableView!
    
    let K = Constants()
    let searchController = UISearchController(searchResultsController: nil)
    
    static var selectedAPI = "Select API"
    var artistHits = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
        }
    }
    var collections = [String]()
    var searchQuery = ""
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTable.delegate = self
        searchTable.dataSource = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter artist name"
        
        searchTable.register(CustomCell.self, forCellReuseIdentifier: K.searchTable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults.object(forKey: K.userDefaultsKey) as? String == API.Apple.rawValue {
            selectedAPI(name: API.Apple.rawValue)
        } else if defaults.object(forKey: K.userDefaultsKey) as? String == API.Napster.rawValue {
            selectedAPI(name: API.Napster.rawValue)
        } else if defaults.object(forKey: K.userDefaultsKey) == nil {
            defaults.setValue("Select API", forKey: K.userDefaultsKey)
        }
        
        let apiSelect = UIBarButtonItem(title: defaults.object(forKey: K.userDefaultsKey) as? String, style: .plain, target: self, action: #selector(promptAPISelect))
        navigationItem.rightBarButtonItems = [apiSelect]
        selectedAPI(name: SearchViewController.selectedAPI)
    }
}
    
    //MARK: - Search Bar and Controller Delegates

extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            artistHits = []
        } else {
            if SearchViewController.selectedAPI == API.Apple.rawValue {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    SearchManager.instance.getArtists(search: searchText) { [self] (namesResponse, collectionResponse) in
                        (self!.artistHits, self!.collections) = (namesResponse, collectionResponse)
                    }
                }
            } else if SearchViewController.selectedAPI == API.Napster.rawValue {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    SearchManager.instance.getNapsterArtists(searchText, completion: { response in
                        self?.artistHits = response
                    })
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        artistHits = []
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
        guard let detail = storyboard?.instantiateViewController(identifier: K.collectionViewID) as? ViewController else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        
        SearchViewController.selectedAPI == API.Apple.rawValue ? {
            detail.resultName = ("\(artistHits[indexPath.row]) \(collections[indexPath.row])")
            detail.selectedAPI = SearchViewController.selectedAPI
        }() : {
            detail.resultName = artistHits[indexPath.row]
            detail.selectedAPI = SearchViewController.selectedAPI
        }()
        
        navigationController?.pushViewController(detail, animated: true)
    }
}
//MARK: - Class methods

extension SearchViewController {
    @objc func promptAPISelect() {
        guard let APISelectVC = storyboard?.instantiateViewController(identifier: K.apiID) as? APISelectVC else { return }
        navigationController?.pushViewController(APISelectVC, animated: true)
    }
    
    func selectedAPI(name: String) {
        if name == API.Apple.rawValue {
            let api = "https://itunes.apple.com/search?term="
            SearchViewController.selectedAPI = name
            SearchManager.instance.baseURL = api
        } else if name == API.Napster.rawValue {
            let apiKey = "NmJiYmYzNTItOTgyNi00ZjdmLTgxZDYtYWVkYmI0NDVlOWQ4"
            let api = "https://api.napster.com/v2.2/search?apikey=\(apiKey)&type=artist&query="
            SearchViewController.selectedAPI = name
            SearchManager.instance.baseURL = api
        }
    }
}
