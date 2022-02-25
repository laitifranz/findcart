
//
//  CustomTableViewCell.swift
//  ViewST
//
//  Created by Francesco Laiti on 07/03/18.
//  Copyright © 2018 francescolaiti. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var nomeCella: UILabel!
    @IBOutlet var statoCella: UILabel!
    @IBOutlet var cellaView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
