//
//  Location.swift
//  uMAPit
//
//  Created by Hassan Abid on 16/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import Foundation
import RealmSwift


class Location: Object {

    dynamic var title = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var address = ""
    dynamic var updated_at: Date? = nil
    dynamic var created_at: Date? = nil
    dynamic var id = 0

}
