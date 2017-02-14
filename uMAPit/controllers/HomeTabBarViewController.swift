//
//  HomeTabBarViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 12/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit

class HomeTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("HomeTabBarViewController - viewDidLoad")
        self.delegate = self
        self.selectedIndex = 0
        
        self.tabBar.barTintColor = UIColor(red: 77/255, green: 195/255, blue: 58/255, alpha: 1.0)
        
        tabBarController(self, didSelect: self.selectedViewController!)
        
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if(viewController.isKind(of: ProfileViewController.self)) {
            print("profileviewcontroller")
        }
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
