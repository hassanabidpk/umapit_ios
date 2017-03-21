//
//  Constants.swift
//  uMAPit
//
//  Created by Hassan Abid on 12/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import Foundation


struct Constants {


    static let BASE_LOGIN_URL_LOCAL = "http://localhost:8000/rest-auth/login/"
    static let BASE_LOGIN_URL = "https://umapit.azurewebsites.net/rest-auth/login/"
    
    static let BASE_USER_URL_LOCAL = "http://localhost:8000/rest-auth/user/"
    static let BASE_USER_URL = "https://umapit.azurewebsites.net/rest-auth/user/"
    
    static let BASE_LOGOUT_URL_LOCAL = "http://localhost:8000/rest-auth/logout/"
    static let BASE_LOGOUT_URL = "https://umapit.azurewebsites.net/rest-auth/logout/"
    
    static let tintColor = UIColor(red: 88/255.0, green: 93/255.0, blue: 87/255.0, alpha: 1.0)

}
