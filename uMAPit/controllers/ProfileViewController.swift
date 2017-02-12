//
//  ProfileViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 12/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.actionLogoutUser(_:)))
        logoutButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = logoutButton

        
    }
    
    // MARK - Helper methods
    
    
    func actionLogoutUser(_ sender:UIBarButtonItem) {
        
        print("logout")
        
        Alamofire.request(Constants.BASE_LOGOUT_URL).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Logout Successful")
            case .failure(let error):
                print(error)
            }
        }
        self.dismiss(animated: true, completion: nil)
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
