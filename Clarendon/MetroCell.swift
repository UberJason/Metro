//
//  MetroCell.swift
//  Metro
//
//  Created by Jason Ji on 10/9/16.
//  Copyright © 2016 Jason Ji. All rights reserved.
//

import UIKit

class MetroCell: UITableViewCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
