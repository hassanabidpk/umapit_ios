//
//  Comment.swift
//  uMAPit
//
//  Created by Hassan Abid on 26/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import Foundation
import RealmSwift

class Comment: Object {

    dynamic var id = 0
    dynamic var text = ""
    dynamic var approved_comment = false
    dynamic var created_at: Date? = nil
    
    dynamic var user: User?
    dynamic var place: Place?
}
