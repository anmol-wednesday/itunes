//
//  SearchViewController.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 21/04/21.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating {
    @IBOutlet weak var searchTable: UITableView!
    let K = Constants()
    let searchController = UISearchController(searchResultsController: nil)
    
    static var selectedAPI = "Select API"
    var artistHits = [String]()
    var collections = [String]()
    var searchQuery = ""
    var defaults = UserDefaults.standard
    
    var albums = [Album]()
    var napsterAlbums = [NapsterAlbums]()
    var common = [CollectionCellData]()
    
    var count: Int?
    
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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter artist name"
        searchController.definesPresentationContext = true
    }
    
    //MARK: - UISearchContoller Method

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text else { return }
        if SearchViewController.selectedAPI == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getArtists(search: searchQuery) { [self] (namesResponse, collectionResponse) in
                    (self!.artistHits, self!.collections) = (namesResponse, collectionResponse)
                }
            }
            
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
            
        } else if SearchViewController.selectedAPI == API.Napster.rawValue {
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.artistHits = SearchManager.instance.getNapsterArtists(searchQuery)
            }
            
            DispatchQueue.main.async {
                self.searchTable.reloadData()
            }
            
        } else {
            artistHits = []
        }
        searchTable.reloadData()
    }
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
        common = []
        var value = ""
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        
        if SearchViewController.selectedAPI == API.Apple.rawValue {
            value = ("\(artistHits[indexPath.row]) \(collections[indexPath.row])")
        } else if SearchViewController.selectedAPI == API.Napster.rawValue {
            value = artistHits[indexPath.row]
        }
        getCollectionViewData(for: value)
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
    
    func showAlert() {
        let alert = UIAlertController(title: K.errorTitle, message: "\(K.error)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getCollectionViewData(for value: String) {
        guard let detail = storyboard?.instantiateViewController(identifier: "AlbumCollection") as? ViewController else { return }
        if SearchViewController.selectedAPI == API.Apple.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let search = value
                SearchManager.instance.getAlbum(searchRequest: search) { (requestedAlbums) in
                    self?.albums = requestedAlbums
                    
                    for album in self!.albums {
                        if self?.common.count == 49 {
                            break
                        }
                        let image = album.artwork
                        let name = album.artistName
                        let song = album.songName
                        let collection = album.collectionName
                        let cellInfo = CollectionCellData(image: image, artistName: name, trackName: song, collectionName: collection)
                        self?.common.append(cellInfo)
                    }
                    detail.cellData = self!.common
                    detail.resultName = value
                    detail.selectedAPI = API.Apple.rawValue
                    self?.count = detail.cellData.count
                    DispatchQueue.main.async {
                        if self?.count == 0 {
                            self!.showAlert()
                        } else {
                            self?.navigationController?.pushViewController(detail, animated: true)
                        }
                    }
                }
                
            }
        } else if SearchViewController.selectedAPI == API.Napster.rawValue {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                SearchManager.instance.getNapsterAlbums(string: value) { (request) in
                    self?.napsterAlbums = request
                    if let counter = self?.napsterAlbums[0].albumID.count {
                        for i in 0..<counter {
                            let image = self?.napsterAlbums[0].albumID[i]
                            let name = value
                            let cellInfo = CollectionCellData(image: image ?? "alb.301258656", artistName: name, trackName: image ?? "alb.301258656", collectionName: image ?? "alb.301258656")
                            self?.common.append(cellInfo)
                        }
                        detail.cellData = self!.common
                        self?.count = self?.common.count
                    }
                }
                detail.selectedAPI = API.Napster.rawValue
                detail.resultName = value
            }
            
            DispatchQueue.main.async {
                if self.count == 0 {
                    print(self.common.count)
                    self.showAlert()
                } else {
                    self.navigationController?.pushViewController(detail, animated: true)
                }
            }
        }
    }
}
