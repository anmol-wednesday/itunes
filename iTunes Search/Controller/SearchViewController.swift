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
    var artistHits = [String]()
    var collections = [String]()
    var searchQuery = ""
    var defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults.object(forKey: "SelectedAPI") as? String == API.Apple.rawValue {
            appleAPI(name: API.Apple.rawValue)
        } else if defaults.object(forKey: "SelectedAPI") as? String == API.Napster.rawValue {
            napsterAPI(name: API.Napster.rawValue)
        } else if defaults.object(forKey: "SelectedAPI") == nil {
            defaults.setValue("Select API", forKey: "SelectedAPI")
        }
        
        let apiSelect = UIBarButtonItem(title: defaults.object(forKey: "SelectedAPI") as? String, style: .plain, target: self, action: #selector(promptAPISelect))
        navigationItem.rightBarButtonItems = [apiSelect]
        selectedAPI(name: SearchViewController.selectedAPI)
    }
    
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
    }
}
    
    //MARK: - Search Bar and Controller Delegates

extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            return
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
            searchTable.reloadData()
        }
    }
    
//    func didDismissSearchController(_ searchController: UISearchController) {
//        artistHits.removeAll(keepingCapacity: true)
//    }
}

//MARK: - UITableView Delegate and Datasource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistHits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artist", for: indexPath)
        
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
        guard let detail = storyboard?.instantiateViewController(identifier: "AlbumCollection") as? ViewController else { return }
        var value = ""
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        
        if SearchViewController.selectedAPI == API.Apple.rawValue {
            value = ("\(artistHits[indexPath.row]) \(collections[indexPath.row])")
            detail.resultName = value
            detail.selectedAPI = API.Apple.rawValue
        }
        if SearchViewController.selectedAPI == API.Napster.rawValue {
            value = artistHits[indexPath.row]
            detail.resultName = value
            detail.selectedAPI = API.Napster.rawValue
        }
        navigationController?.pushViewController(detail, animated: true)
    }
}

//MARK: - Class methods

extension SearchViewController {
    
    @objc func promptAPISelect() {
        guard let APISelectVC = storyboard?.instantiateViewController(identifier: "apiVC") as? APISelectVC else { return }
        navigationController?.pushViewController(APISelectVC, animated: true)
    }
    
    func appleAPI(name: String) {
        let api = "https://itunes.apple.com/search?term="
        SearchViewController.selectedAPI = name
        SearchManager.instance.baseURL = api
    }
    
    func napsterAPI(name: String) {
        SearchViewController.selectedAPI = name
        let apiKey = "NmJiYmYzNTItOTgyNi00ZjdmLTgxZDYtYWVkYmI0NDVlOWQ4"
        let api = "https://api.napster.com/v2.2/search?apikey=\(apiKey)&type=artist&query="
        SearchManager.instance.baseURL = api
    }
    
    func selectedAPI(name: String) {
        if name == API.Apple.rawValue {
            appleAPI(name: SearchViewController.selectedAPI)
        } else if name == API.Napster.rawValue {
            napsterAPI(name: SearchViewController.selectedAPI)
        }
    }
}
