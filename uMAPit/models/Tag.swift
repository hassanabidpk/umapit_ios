//
//  File.swift
//  uMAPit
//
//  Created by Hassan Abid on 16/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import Foundation
import RealmSwift

class Tag: Object {
    
    dynamic var id = 0
    dynamic var title = ""
    dynamic var slug = ""

    let places = LinkingObjects(fromType: Place.self, property: "place_tags")
    
}
