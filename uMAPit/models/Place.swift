//
//  Place.swift
//  uMAPit
//
//  Created by Hassan Abid on 16/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import Foundation
import RealmSwift

class Place: Object {

    dynamic var name = ""
    dynamic var description_place = ""
    dynamic var slug = ""
    dynamic var image_1 = ""
    dynamic var image_2 = ""
    dynamic var image_3 = ""
    dynamic var image_4 = ""
    dynamic var updated_at: Date? = nil
    dynamic var created_at: Date? = nil
    dynamic var id = 0
    dynamic var like_count = 0
    dynamic var flag_count = 0
    
    dynamic var user: User?
    dynamic var location: Location?
    let place_tags = List<Tag>()
    
    
    

}
