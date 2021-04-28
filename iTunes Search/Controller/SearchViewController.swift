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
    var artistHits = [Artists]()
    var artists = [NapsterArtists]()
    var selectedAPI = "Apple"
    var searchQuery = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        let appleAPI = UIBarButtonItem(image: UIImage(named: "apple-logo-removebg-preview"), style: .plain, target: self, action: #selector(appleAPI))
        let otherAPI = UIBarButtonItem(image: UIImage(named: "napster-logo-vector-3-removebg-preview"), style: .plain, target: self, action: #selector(otherAPI))
        navigationItem.rightBarButtonItems = [appleAPI, otherAPI]
        searchTable.delegate = self
        searchTable.dataSource = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter artist name"
        searchController.definesPresentationContext = true
        title = "Search"
        navigationItem.searchController = searchController
        showAlert(selectedAPI)
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text else { return }
        if selectedAPI == "Apple"{
            SearchManager.instance.getArtists(search: searchQuery) { (requestedArtists) in
                self.artistHits = []
                self.artistHits = requestedArtists
                DispatchQueue.main.async {
                    self.searchTable.reloadData()
                }
            }
        } else {
            SearchManager.instance.getNapsterArtists(searchQuery)
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
        }
    }
    @objc func appleAPI() {
        let api = "https://itunes.apple.com/search?term="
        let name = "Apple"
        selectedAPI = name
        showAlert(name)
        SearchManager.instance.baseURL = api
    }
    @objc func otherAPI() {
        let name = "Napster"
        selectedAPI = name
        let apiKey = "NmJiYmYzNTItOTgyNi00ZjdmLTgxZDYtYWVkYmI0NDVlOWQ4"
        let api = "https://api.napster.com/v2.2/search?apikey=\(apiKey)&type=artist&query="
        showAlert(name)
        SearchManager.instance.baseURL = api
    }
    func showAlert(_ name: String) {
        let alert = UIAlertController(title: "API Switched", message: "The API has switched to \(name) API.", preferredStyle: .alert)
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
        cell.textLabel?.text = artistHits[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        guard let detail = storyboard?.instantiateViewController(identifier: "AlbumCollection") as? ViewController else { return }
        if selectedAPI == "Apple"{
            SearchManager.instance.getAlbum(searchRequest: artistHits[indexPath.row].name) { (requestedAlbums) in
                detail.albums = requestedAlbums
                detail.resultName = self.artistHits[indexPath.row].name
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(detail, animated: true)
                }
            }
        } else {
            // Implement SearchManager.instance.getNapsterAlbums()
        }
    }
}
