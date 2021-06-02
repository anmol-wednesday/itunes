//
//  SearchView.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 25/05/21.
//

import UIKit

class SearchView: UIView {
    var searchTable: UITableView = {
        let searchTableView = UITableView()
        searchTableView.translatesAutoresizingMaskIntoConstraints = false
        searchTableView.sizeToFit()
        searchTableView.backgroundColor = UIColor(named: "viewColor")
        return searchTableView
    }()
    
    var spinner: UIActivityIndicatorView = {
        let spin = UIActivityIndicatorView(style: .large)
        spin.hidesWhenStopped = true
        spin.translatesAutoresizingMaskIntoConstraints = false
        spin.isHidden = true
        return spin
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchTable)
        addSubview(spinner)
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: searchTable.centerXAnchor),
            
            searchTable.topAnchor.constraint(equalTo: self.topAnchor),
            searchTable.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            searchTable.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            searchTable.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
