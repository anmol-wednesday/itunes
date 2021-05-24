//
//  APIViewModel.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 24/05/21.
//

import Foundation
import UIKit.UITableView

class APIViewModel {
    let K = Constants()
    let apiNames = [API.Apple.rawValue, API.Napster.rawValue]
    let searchVC = SearchViewController()
    
    var selectedIndexPath = IndexPath(row: 2, section: 0)
    
    func checkCell(with indexPath: IndexPath, for tableView: UITableView, completion: @escaping () -> Void) {
        if indexPath == selectedIndexPath {
            return
        }
        
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
                } else if cellName == API.Napster.rawValue {
                    print(cellName)
                    SearchViewController.selectedAPI = API.Napster.rawValue
                    searchVC.defaults.setValue(API.Napster.rawValue, forKey: K.userDefaultsKey)
                }
            }
        }
        completion()
    }
}
