//
//  APISelectVC.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 04/05/21.
//

import UIKit

class APISelectVC: UITableViewController {
    let K = Constants()
    let searchVC = SearchViewController()
    let apiNames = ["Apple", "Napster"]
    var checked = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checked = Array(repeating: false, count: apiNames.count)
        
        title = "Select API"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "API", for: indexPath)
        
        if checked[indexPath.row] == false {
            cell.accessoryType = .none
        } else if checked[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        
        cell.textLabel?.text = apiNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                checked[indexPath.row] = false
                
            } else {
                cell.accessoryType = .checkmark
                checked[indexPath.row] = true
            }
            
            if let cellName = cell.textLabel?.text {
                if cellName == K.apple {
                    print(cellName)
                    SearchViewController.selectedAPI = K.apple
                } else if cellName == K.napster {
                    print(cellName)
                    SearchViewController.selectedAPI = K.napster
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}
