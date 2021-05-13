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
    let apiNames = [API.Apple.rawValue, API.Napster.rawValue]
    let defaults = UserDefaults.standard
    var selectedIndexPath = IndexPath(row: 2, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = false
        title = "Select API"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.apiTable, for: indexPath)
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        cell.textLabel?.text = apiNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        checkCell(with: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func checkCell(with indexPath: IndexPath) {
        if indexPath == selectedIndexPath {
            return
        }
        
        //use user defaults for checkmark
        
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.accessoryType == UITableViewCell.AccessoryType.none {
            newCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        let oldCell = tableView.cellForRow(at: selectedIndexPath)
        if oldCell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            oldCell?.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        selectedIndexPath = indexPath
        if let cell = tableView.cellForRow(at: indexPath) {
            if let cellName = cell.textLabel?.text {
                if cellName == API.Apple.rawValue {
                    print(cellName)
                    SearchViewController.selectedAPI = API.Apple.rawValue
                    searchVC.defaults.setValue(API.Apple.rawValue, forKey: K.userDefaultsKey)
                    navigationController?.popToRootViewController(animated: true)
                } else if cellName == API.Napster.rawValue {
                    print(cellName)
                    SearchViewController.selectedAPI = API.Napster.rawValue
                    searchVC.defaults.setValue(API.Napster.rawValue, forKey: K.userDefaultsKey)
                    navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}
