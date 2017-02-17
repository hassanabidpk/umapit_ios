//
//  PlaceTableViewCell.swift
//  uMAPit
//
//  Created by Hassan Abid on 17/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

 
    
    @IBOutlet weak var placeImage: UIImageView!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var flagLabel: UILabel!
    
    @IBOutlet weak var placeUser: UILabel!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
