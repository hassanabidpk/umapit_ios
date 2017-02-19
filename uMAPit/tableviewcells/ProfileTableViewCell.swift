//
//  ProfileTableViewCell.swift
//  uMAPit
//
//  Created by Hassan Abid on 19/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

   
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
