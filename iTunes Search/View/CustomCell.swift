//
//  CustomCell.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 13/05/21.
//

import UIKit

class CustomCell: UITableViewCell {
    
    let K = Constants()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: K.searchTable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
