//
//  ProfileViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 12/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import Kingfisher


#if DEBUG
    let BASE_USER_URL = "http://localhost:8000/rest-auth/user/"
    let BASE_LOGOUT_URL = "http://localhost:8000/rest-auth/logout/"
#else
    let BASE_USER_URL = "https://umapit.azurewebsites.net/rest-auth/user/"
    let BASE_LOGOUT_URL = "https://umapit.azurewebsites.net/rest-auth/logout/"
#endif

class ProfileViewController: UIViewController {

    
    static let GRAVATAR_IMAGE_URL = "https://www.gravatar.com/avatar/"
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(actionLogoutUser(_:)))
        logoutButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = logoutButton
        
        self.getUserDetails()

        
    }
    

    // MARK - Helper methods
    
    func getUserDetails() {
        
        let userDefaults = UserDefaults.standard
        let username = userDefaults.value(forKey: "username")
        let results = try! Realm().objects(User.self).filter("username = \(username!)")
        
        if(results.count > 0) {
            
            let user = results[0]
            
            self.setUserUI(first_name: user.first_name, last_name: user.last_name, email: user.email)
        
        
        } else  {
        
            let strToken = userDefaults.value(forKey: "userToken")
            let authToken = "Token \(strToken!)"
        
            let headers = [
                "Authorization": authToken
            ]
        
            Alamofire.request(BASE_USER_URL, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                .responseJSON  { response in
        
                debugPrint(response)
                
                    if let userDetails = response.result.value {
                        let json = JSON(userDetails)
                        if let first_name = json["first_name"].string,
                            let last_name = json["last_name"].string,
                            let username = json["username"].string,
                            let email = json["email"].string {
                        
                            print("token: \(json) with firstName: \(first_name)")
                        
                            let realm = try! Realm()
                            realm.beginWrite()
                        
                            realm.create(User.self, value: ["first_name" : first_name,
                                                        "last_name" : last_name,
                                                        "email" : email,
                                                        "username" : username,
                                                        "pk" : json["pk"].intValue ])
                        
                            try! realm.commitWrite()
                        
                            self.setUserUI(first_name: first_name, last_name: last_name, email: email)
                        
                        
                        } else {
                            print("login failed \(userDetails)")
                        }
        
                    }
        
    
                }
            
            }
    }
    
    
    func actionLogoutUser(_ sender:UIBarButtonItem) {
        
        print("logout")
        
        Alamofire.request(BASE_LOGOUT_URL).validate().responseJSON { response in
            switch response.result {
            case .success:
                let userDefaults = UserDefaults.standard
                userDefaults.removeObject(forKey: "userToken")
                userDefaults.removeObject(forKey: "username")
                userDefaults.synchronize()
                
                self.deleteAllRealmDB()
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingPageViewController") as! LandingPageViewController
                
                let appDel:UIApplicationDelegate  = UIApplication.shared.delegate!
                
                appDel.window??.rootViewController = loginVC
                print("Logout Successful")
            case .failure(let error):
                print(error)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func deleteAllRealmDB() {
        
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            print("deleted realm db because user has logout");
        }
    }
    
    func setUserUI(first_name: String, last_name: String, email: String ) {
    
        self.name.text = "\(first_name) \(last_name)"
        let hash = email.md5
        
        self.profileImage.kf.setImage(with: URL(string: "\(ProfileViewController.GRAVATAR_IMAGE_URL)\(hash)?s=150")!,
                                      placeholder: nil,
                                      options: [.transition(.fade(1))],
                                      progressBlock: nil,
                                      completionHandler: nil)
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
