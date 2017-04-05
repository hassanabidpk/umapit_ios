//
//  NewPlaceViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 26/03/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import ImagePicker
import Alamofire
import SwiftyJSON
import RealmSwift
import PKHUD

#if DEBUG
    let PLACE_CREATE_API_URL = "http://localhost:8000/place/api/v1/list/new/"
#else
    let PLACE_CREATE_API_URL = "https://umapit.azurewebsites.net/place/api/v1/list/new/"
#endif


class NewPlaceViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, ImagePickerDelegate {
    
    
    @IBOutlet weak var addPhotosButton: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var placeNameTextField: UITextField!
    
    var location: Location?

    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var tagTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var mapitButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        configureViews()
    
    }
    
    
    // MARK: - IBActions
    
    @IBAction func didPressMapIt(_ sender: Any) {
        
        print("didPressMapIt")
        
        let userDefaults = UserDefaults.standard
        
        let strToken = userDefaults.value(forKey: "userToken")
        let authToken = "Token \(strToken!)"
        
        let headers = [
            "Authorization": authToken
        ]
        
        if let place_name = self.placeNameTextField.text, let loc = location, let tags = self.tagTextField.text {
            
            HUD.show(.progress)
            
            let parameters: Parameters = ["name": place_name,
                                      "description": self.descriptionTextView.text,
                                      "slug" : "location-slug",
                                      "location" : loc.id,
                                      "tags": tags]
                
            Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        if let image1 = self.imageView1.image {
                            let imageData1 = UIImageJPEGRepresentation(image1, 0.8)
                            multipartFormData.append(imageData1!, withName: "image_1", fileName: "photo_1.jpg", mimeType: "jpg/png")
                        }
                        if let image2 = self.imageView2.image {
                            let imageData2 = UIImageJPEGRepresentation(image2, 0.8)
                            multipartFormData.append(imageData2!, withName: "image_2", fileName: "photo_2.jpg", mimeType: "jpg/png")
                        }
                        if let image3 = self.imageView3.image {
                            let imageData3 = UIImageJPEGRepresentation(image3, 0.8)
                            multipartFormData.append(imageData3!, withName: "image_3", fileName: "photo_3.jpg", mimeType: "jpg/png")
                        }
                        if let image4 = self.imageView4.image {
                            let imageData4 = UIImageJPEGRepresentation(image4, 0.8)
                            multipartFormData.append(imageData4!, withName: "image_4", fileName: "photo_4.jpg", mimeType: "jpg/png")
                        }
                        for (key, value) in parameters {
                            if value is String || value is Int {
                                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                            }
                        }
                },
                    to: PLACE_CREATE_API_URL,
                    headers: headers,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                debugPrint(response)
                                if let placeStatus = response.result.value {
                                    
                                    let json = JSON(placeStatus)
                                    print("new place JSON: \(json)")
                                    if let new_place_name = json["name"].string {
                                        
                                        print("writing new place to REALM db")
                                        let realm = try! Realm()
                                        realm.beginWrite()
                                        
                                        let new_place = realm.create(Place.self, value: ["name": new_place_name,
                                                                                         "description_place": json["description"].stringValue,
                                                                                         "created_at": self.dateFromStringConverter(date: json["created_at"].stringValue)!,
                                                                                         "updated_at": self.dateFromStringConverter(date: json["updated_at"].stringValue)!,
                                                                                         "id": json["id"].int!,
                                                                                         "image_1": json["image_1"].stringValue,
                                                                                         "image_2": json["image_2"].stringValue,
                                                                                         "image_3": json["image_3"].stringValue,
                                                                                         "image_4": json["image_4"].stringValue,
                                                                                         "slug": json["slug"].stringValue,
                                                                                         "like_count": 0,
                                                                                         "flag_count": 0])
                                        
                                        
                                        new_place.location = loc
                                        
                                        let user = json["user"]
                                        let existing_user = try! Realm().objects(User.self).filter("id = \(user["id"].int!)")
                                        new_place.user = existing_user[0]
                                        
                                        let places_tags = json["place_tags"].array
                                        
                                        for tag in places_tags! {
                                            
                                            let existing_tag = try! Realm().objects(Tag.self).filter("id = \(tag["id"].int!)")
                                            
                                            if(existing_tag.count < 1) {
                                                
                                                let new_tag = realm.create(Tag.self, value: ["title": tag["title"].stringValue,
                                                                                             "id": tag["id"].int!,
                                                                                             "slug": tag["slug"].stringValue])
                                                print("new_tag : \(new_tag)")
                                                new_place.place_tags.append(new_tag)
                                                
                                            } else {
                                                
                                                new_place.place_tags.append(existing_tag[0])
                                            }
                                            
                                            
                                        }
                                        
                                        try! realm.commitWrite()
                                        
                                        self.showFeedViewController()
                                        
                                    } else {
                                        
                                        HUD.flash(.error, delay: 1.0)
                                        print("error posting new place")
                                        
                                    }
                                }

                            }
                        case .failure(let encodingError):
                            print("encoding Error : \(encodingError)")
                            HUD.flash(.error, delay: 1.0)
                        }
                })
        
        } else {
            HUD.flash(.error, delay: 1.0)
        }
    }
    
    @IBAction func didPressAddPhotos(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 4
        present(imagePickerController, animated: true, completion: nil)

    }
    
    
    // MARK : - Helpers
    
    func configureViews() {
    
        Configuration.doneButtonTitle = "DONE"
        Configuration.noImagesTitle = "Sorry! There are no images here!"
        
        mapitButton.backgroundColor = UIColor(red: 77/255, green: 195/255, blue: 58/255, alpha: 1.0)
        
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.borderWidth = 1.0;
        descriptionTextView.layer.cornerRadius = 5.0;
        
        placeNameTextField.returnKeyType = .next
        placeNameTextField.clearButtonMode = .never
        
        tagTextField.returnKeyType = .next
        tagTextField.clearButtonMode = .never
        

        descriptionTextView.returnKeyType = .default
        
        placeNameTextField.delegate = self
        tagTextField.delegate = self
        
        descriptionTextView.delegate = self
        
        
    }
    
    
    // MARK: - TextField Delegate 
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        KeyboardAvoiding.avoidingView = nil
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if( textField == placeNameTextField ) {
            
            textField.resignFirstResponder()
            tagTextField.becomeFirstResponder()
        } else if (textField == tagTextField) {
            
            
            textField.resignFirstResponder()
            self.descriptionTextView.becomeFirstResponder()
        } else {
            
            self.descriptionTextView.resignFirstResponder()
        }
        return true
        
    }
    
    
    // MARK- TextView Delegate 
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        KeyboardAvoiding.avoidingView = self.view
        return true
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    // MARK: - ImagePicker Delegate 
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        switch(images.count) {
            case 1 :
                imageView1.image = images[0]
                break
            case 2 :
                imageView1.image = images[0]
                imageView2.image = images[1]
                break
            case 3 :
                imageView1.image = images[0]
                imageView2.image = images[1]
                imageView3.image = images[2]
                break
            case 4 :
                imageView1.image = images[0]
                imageView2.image = images[1]
                imageView3.image = images[2]
                imageView4.image = images[3]
                break
            default: break
        
        }

    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Helpers
    
    func dateFromStringConverter(date: String)-> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //or you can use "yyyy-MM-dd'T'HH:mm:ssX"
        
        return dateFormatter.date(from: date)
    }

    func showFeedViewController() {
        
        HUD.flash(.success, delay: 1.0) { finished in
            
            print("viewcontrollers : \(self.navigationController?.viewControllers)")
            if let feedVC = self.navigationController?.viewControllers[0] as? FeedViewController {
                
                feedVC.reloadTableView()
            }
            
            let _ = self.navigationController?.popToRootViewController(animated: true)

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
