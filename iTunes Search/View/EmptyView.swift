//
//  EmptyView.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 13/05/21.
//

import UIKit

class EmptyView: UIView {
    let errorMessage: UILabel = {
        let label = UILabel()
        label.text = "No Results Found"
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let errorDescription: UILabel = {
        let label = UILabel()
        label.text = "No results were found for this artist."
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        addSubview(errorMessage)
        addSubview(errorDescription)

        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: errorMessage.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: errorMessage.centerYAnchor),
            
            errorDescription.topAnchor.constraint(equalTo: errorMessage.bottomAnchor, constant: 8),
            errorDescription.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
