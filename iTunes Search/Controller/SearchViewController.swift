//
//  SearchViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 21/04/21.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating {
    @IBOutlet weak var searchTable: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    let K = Constants()
    
    var artistHits = [String]()
    var selectedAPI: String?
    var searchQuery = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appleAPI = UIBarButtonItem(image: UIImage(named: "apple"), style: .plain, target: self, action: #selector(appleAPI))
        let napsterAPI = UIBarButtonItem(image: UIImage(named: "napster"), style: .plain, target: self, action: #selector(napsterAPI))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItems = [napsterAPI, appleAPI]
        
        searchTable.delegate = self
        searchTable.dataSource = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter artist name"
        searchController.definesPresentationContext = true
        
        let alert = UIAlertController(title: K.selectTitle, message: K.select, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text else { return }
        
        if selectedAPI == K.apple {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getArtists(search: searchQuery) { (requestedArtists) in
                    self?.artistHits = requestedArtists
                }
            }
            
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
        } else if selectedAPI == K.napster {
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.artistHits = SearchManager.instance.getNapsterArtists(searchQuery)
            }
            
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
            
        } else {
            artistHits = []
        }
    }
    
    @objc func appleAPI() {
        let api = "https://itunes.apple.com/search?term="
        let name = K.apple
        selectedAPI = name
        showAlert(name)
        artistHits = []
        SearchManager.instance.baseURL = api
    }
    
    @objc func napsterAPI() {
        let name = K.napster
        selectedAPI = name
        let apiKey = "NmJiYmYzNTItOTgyNi00ZjdmLTgxZDYtYWVkYmI0NDVlOWQ4"
        let api = "https://api.napster.com/v2.2/search?apikey=\(apiKey)&type=artist&query="
        showAlert(name)
        artistHits = []
        SearchManager.instance.baseURL = api
    }
    
    func showAlert(_ name: String) {
        let alert = UIAlertController(title: K.apiTitle, message: "\(K.api)\(name) API.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistHits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artist", for: indexPath)
        cell.textLabel?.text = artistHits[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        guard let detail = storyboard?.instantiateViewController(identifier: "AlbumCollection") as? ViewController else { return }
        if selectedAPI == K.apple {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getAlbum(searchRequest: (self?.artistHits[indexPath.row])!) { (requestedAlbums) in
                    detail.albums = requestedAlbums
                    detail.resultName = (self?.artistHits[indexPath.row])!
                    detail.selectedAPI = (self?.K.apple)!
                }
            }
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(detail, animated: true)
            }
        } else if selectedAPI == K.napster {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterAlbums(string: (self?.artistHits[indexPath.row])!) { (request) in
                    detail.napster = request
                }
                
                detail.selectedAPI = (self?.K.napster)!
                detail.resultName = (self?.artistHits[indexPath.row])!
            }
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(detail, animated: true)
            }
        }
    }
}
