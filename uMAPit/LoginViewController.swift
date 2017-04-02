//
//  ViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 16/01/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import IHKeyboardAvoiding

#if DEBUG
    let BASE_LOGIN_URL = "http://localhost:8000/rest-auth/login/"
#else
    let BASE_LOGIN_URL = "https://umapit.azurewebsites.net/rest-auth/login/"
#endif
class LoginViewController: UIViewController, UITextFieldDelegate {
    

    // MARK - properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    
    
    
    // MARK - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForToken()
        setupUI()
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.loginSpinner.stopAnimating()
        
//        KeyboardAvoiding.avoidingView = self.loginButton
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK - UI
    
    
    func setupUI() {
        
        usernameTextField.returnKeyType = .next
        usernameTextField.clearButtonMode = .never
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.clearButtonMode = .never
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    
    
    }
    
    func handleKeyboardNotification(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        // Get information about the animation.
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).uintValue
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurveValue)
        
        
        // Animate updating the view's layout by calling layoutIfNeeded inside a UIView animation block.
        let animationOptions: UIViewAnimationOptions = [animationCurve, .beginFromCurrentState]
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    // MARK - Actions 
    
    @IBAction func loginUser(_ sender: UIButton) {
        
        self.loginSpinner.startAnimating()
        
        
        if let username = usernameTextField.text, let password = passwordTextField.text {
        
             print("username: \(username)")
            
            Alamofire.request(BASE_LOGIN_URL, method: .post, parameters: ["username": username,
                "password": password])
                .responseJSON {response in
                    
                    print(response.request ?? "")  // original URL request
                    print(response.response ?? "") // URL response
                    print(response.data ?? "")     // server data
                    print(response.result)   // result of response serialization
                    
                    
                    if let loginStatus = response.result.value {
                        
                        let json = JSON(loginStatus)
                        if let strToken = json["key"].string {
                            
                            print("token: \(strToken)")
                            self.loginSpinner.stopAnimating()
                            self.saveUserDefaults(strToken: strToken, userName: username)
                            HUD.flash(.success, delay: 1.0) { finished in
                                
                                self.startHomeController()
                            }
                            
                            
                        } else {
                            
                            print("login failed \(loginStatus)")
                            self.loginSpinner.stopAnimating()
                            HUD.flash(.error, delay: 1.0) { finished in
                                self.showLoginAlert()
                                self.passwordTextField.text = ""
                                
                            }
                            
                            
                        }
                    
                    } else {
                        
                            self.loginSpinner.stopAnimating()
                            HUD.flash(.error, delay: 1.0)
                    }
                }
            
            
        }
        
    }
    
    
    // MARK - UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if( textField == usernameTextField ) {
            
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            
            textField.resignFirstResponder()
        }
        return true
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    // MARK - helper methods
    
    func saveUserDefaults(strToken : String, userName: String)  {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(strToken, forKey: "userToken")
        userDefaults.set(userName, forKey: "username")
        userDefaults.synchronize()
        
    }
    
    func checkForToken() {
    
        let userDefaults = UserDefaults.standard
        
        if let _ = userDefaults.value(forKey: "userToken") {
        
            print("Logged in user")
            self.startHomeController()
        }
    }
    
    func startHomeController() {
        
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as! HomeTabBarViewController
        
        
        self.present(homeViewController, animated: true, completion: nil)
        
    }
    
    func showLoginAlert() {
        
        let title = NSLocalizedString("Login error", comment: "")
        let message = NSLocalizedString("We could not find an account with this username and password", comment: "")
        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
    
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            print("cancel button clicked")
        }
    
        // Add the action.
        alertController.addAction(cancelAction)
    
        present(alertController, animated: true, completion: nil)
    
    }
    

    

}

