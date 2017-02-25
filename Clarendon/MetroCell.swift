//
//  MetroCell.swift
//  Metro
//
//  Created by Jason Ji on 10/9/16.
//  Copyright © 2016 Jason Ji. All rights reserved.
//

import UIKit

public class MetroCell: UITableViewCell {

    @IBOutlet public weak var lineView: UIView!
    @IBOutlet public weak var destinationLabel: UILabel!
    @IBOutlet public weak var statusLabel: UILabel!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lineView.layer.cornerRadius = lineView.frame.size.width/2
        lineView.layer.masksToBounds = true
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
